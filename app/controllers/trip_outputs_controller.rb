require "rest-client"
require "json"
require "normalize_country"

class TripOutputsController < ApplicationController
  def home
    # We load logged in user last Trip_input data
    @trip_input = TripInput.where(user_id: current_user.id).order(id: :desc).first

    # We take the departure airport
    @airport = Airport.new
    @airport = Airport.where(icao: @trip_input.dep_airport_icao).order(id: :desc).first

    # SQL Distance calculation with 10% margin
    distance_nm = @trip_input.distance_nm
    @margin = 0.1
    margin = @margin * distance_nm

    # SQL Filter on airport_type
    list_airport_type = []
    list_airport_type.push("small_airport")   if @trip_input.small_airport
    list_airport_type.push("medium_airport")  if @trip_input.medium_airport
    list_airport_type.push("large_airport")   if @trip_input.large_airport

    # SQL Filter on National / International flight
    origin_country = Airport.find_by(icao: @trip_input.dep_airport_icao).country
    if @trip_input.international_flight
      list_country = Airport::ACCEPTED_COUNTRIES
    else
      list_country = origin_country
    end

    # SQL query implementing Haversine formula to calculate distance in nm based on GPS coordinates
    sql = "SELECT \
            (((acos(sin(( ? * pi() / 180)) * sin((latitude * pi() / 180)) + cos(( ? * pi() / 180)) \
            * cos((latitude * pi() / 180)) * cos((( ? - longitude) * pi() / 180)))) * 180 / pi()) \
            * 60 ) AS distance, airports.* \
          FROM \
            airports \
          WHERE \
            (((acos(sin(( ? * pi() / 180)) * sin((latitude * pi() / 180)) + cos(( ? * pi() / 180)) \
            * cos((latitude * pi() / 180)) * cos((( ? - longitude) * pi() / 180)))) * 180 / pi()) \
            * 60) <= ? \
          AND \
            (((acos(sin(( ? * pi() / 180)) * sin((latitude * pi() / 180)) + cos(( ? * pi() / 180)) \
            * cos((latitude * pi() / 180)) * cos((( ? - longitude) * pi() / 180)))) * 180 / pi()) \
            * 60) >= ? \
          AND \
            airport_type IN ( ? ) \
          AND \
            airports.country IN ( ? ) \          
          ORDER BY \
             airports.country, airports.airport_type \
          LIMIT 3;"

    @filtered_airports = Airport.find_by_sql [sql, @airport.latitude, @airport.latitude, @airport.longitude, @airport.latitude, @airport.latitude, @airport.longitude, distance_nm + margin, @airport.latitude, @airport.latitude, @airport.longitude, distance_nm - margin, list_airport_type, list_country]
    

    # --------------------------------------------------------------------
    # Openweather API
    # --------------------------------------------------------------------
    # Departure Airport weather
    api_call = RestClient.get 'https://api.openweathermap.org/data/3.0/onecall', {params: {lat:Airport.find_by(icao: @trip_input.dep_airport_icao).latitude, lon:Airport.find_by(icao: @trip_input.dep_airport_icao).longitude, appid:ENV["OPENWEATHERMAP_API"], exclude: "current, minutely", units: "metric"}}
    dep_weather = JSON.parse(api_call)

    # First available weather info hour, index 0
    fly_out_dep_time  = dep_weather["hourly"][0]["dt"]
    first_available_hour = Time.at(fly_out_dep_time).utc.to_datetime.hour
    #first_available_hour = 3

    # Fly-out sunrise and sunset info
    fly_out_sunrise_time = dep_weather["daily"][0]["sunrise"]
    fly_out_sunrise_hour = Time.at(fly_out_sunrise_time).utc.to_datetime.hour
    fly_out_sunset_time = dep_weather["daily"][0]["sunset"]
    fly_out_sunset_hour = Time.at(fly_out_sunset_time).utc.to_datetime.hour
    
    # Fly out weather departure weather between sunrise and sunset hours
    @fly_out_dep_icon  = []
    @fly_out_dep_hour  = []
    @fly_out_dep_descr = []
    
    # case 1: sunrise < current_time < sunset
    #   Departure: today
    if first_available_hour >= fly_out_sunrise_hour and first_available_hour <= (fly_out_sunset_hour - @trip_input.eet_hour)
      offset = 0
      for i in offset..(offset + fly_out_sunset_hour - @trip_input.eet_hour - first_available_hour)
        @fly_out_dep_icon[i]  = dep_weather["hourly"][i]["weather"][0]["icon"]
        @fly_out_dep_hour[i]  = Time.at(dep_weather["hourly"][i]["dt"]).utc.to_datetime.hour
        @fly_out_dep_descr[i] = dep_weather["hourly"][i]["weather"][0]["description"]
      end
    end
    
    # case 2: current_time > sunset
    #   Departure: tomorrow
    if first_available_hour > (fly_out_sunset_hour - @trip_input.eet_hour)
      offset = 24 - first_available_hour + fly_out_sunrise_hour
      for i in offset..(offset + fly_out_sunset_hour - @trip_input.eet_hour - fly_out_sunrise_hour)
        @fly_out_dep_icon[i]  = dep_weather["hourly"][i]["weather"][0]["icon"]
        @fly_out_dep_hour[i]  = Time.at(dep_weather["hourly"][i]["dt"]).utc.to_datetime.hour
        @fly_out_dep_descr[i] = dep_weather["hourly"][i]["weather"][0]["description"]
      end
    end
    
    # case 3: current_time < sunrise
    #   Departure: today
    if first_available_hour < fly_out_sunrise_hour
      offset = fly_out_sunrise_hour - first_available_hour
      for i in offset..(offset + fly_out_sunset_hour - fly_out_sunrise_hour - @trip_input.eet_hour)
        @fly_out_dep_icon[i]  = dep_weather["hourly"][i]["weather"][0]["icon"]
        @fly_out_dep_hour[i]  = Time.at(dep_weather["hourly"][i]["dt"]).utc.to_datetime.hour
        @fly_out_dep_descr[i] = dep_weather["hourly"][i]["weather"][0]["description"]
      end
    end

    # Arrival weather from origin airport
    # Openweathermaps provides:
    #   - hourly: 48  hours  (max 1 overnight)
    #   - daily:  8   days   (more than 1 overnight)
    
    
    
    # Return Date
    if first_available_hour < fly_out_sunset_hour 
      #We take off still today
      @departure_day = "Today"
      if @trip_input.overnights == 0
        @return_day = "Today"
      elsif @trip_input.overnights == 1
        @return_day = "Tomorrow"
      else
        @return_day = "In #{@trip_input.overnights} days"
      end
    else
      # We can't take off today, so it will be tomorrow
      @departure_day = "Tomorrow"
      if @trip_input.overnights == 0 
        @return_day = "Tomorrow"
      elsif @trip_input.overnights == 1
        @return_day = "After-Tomorrow"
      else
        @return_day = "In #{@trip_input.overnights + 1} days"
      end
    end
  end

end

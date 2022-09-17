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
          LIMIT 2;"

    @filtered_airports = Airport.find_by_sql [sql, @airport.latitude, @airport.latitude, @airport.longitude, @airport.latitude, @airport.latitude, @airport.longitude, distance_nm + margin, @airport.latitude, @airport.latitude, @airport.longitude, distance_nm - margin, list_airport_type, list_country]
    
    # --------------------------------------------------------------------
    # --- Openweather API
    # --------------------------------------------------------------------
    # Definitions:
    # ------------
    #   Fly Out = The day we fly from original airport to destination airport
    #   Fly In  = The day we fly from destination airport to original airport
    #
    # ---------------------------------
    # --- Fly out departure airport weather
    # ---------------------------------
    api_call = RestClient.get 'https://api.openweathermap.org/data/3.0/onecall', {params: {lat:Airport.find_by(icao: @trip_input.dep_airport_icao).latitude, lon:Airport.find_by(icao: @trip_input.dep_airport_icao).longitude, appid:ENV["OPENWEATHERMAP_API"], exclude: "current, minutely", units: "metric"}}
    fly_out_dep_weather = JSON.parse(api_call)

    # First available weather info hour, index 0
    fly_out_dep_time  = fly_out_dep_weather["hourly"][0]["dt"]
    first_available_hour = Time.at(fly_out_dep_time).utc.to_datetime.hour

    # Fly-out sunrise and sunset info
    fly_out_sunrise_time = fly_out_dep_weather["daily"][0]["sunrise"]
    fly_out_sunrise_hour = Time.at(fly_out_sunrise_time).utc.to_datetime.hour
    fly_out_sunset_time = fly_out_dep_weather["daily"][0]["sunset"]
    fly_out_sunset_hour = Time.at(fly_out_sunset_time).utc.to_datetime.hour
    
    # Variable init
    @fly_out_dep = []
    fly_out_offset1 = 0
    fly_out_offset2 = 0
    buffer = []
    
    # case 1: sunrise < current_time < sunset
    #   Departure: today
    if first_available_hour >= fly_out_sunrise_hour and first_available_hour <= (fly_out_sunset_hour - @trip_input.eet_hour)
      fly_out_offset1 = 0
      fly_out_offset2 = fly_out_offset1 + fly_out_sunset_hour - @trip_input.eet_hour - first_available_hour
      for i in fly_out_offset1..fly_out_offset2
        hour  = Time.at(fly_out_dep_weather["hourly"][i]["dt"]).utc.to_datetime.hour
        icon  = fly_out_dep_weather["hourly"][i]["weather"][0]["icon"]
        desc = fly_out_dep_weather["hourly"][i]["weather"][0]["description"]
        buffer.push(hour, icon, desc)
        @fly_out_dep.push(buffer)
        buffer = []
      end
    end
    
    # case 2: current_time > sunset
    #   Departure: tomorrow
    if first_available_hour > (fly_out_sunset_hour - @trip_input.eet_hour)
      fly_out_offset1 = 24 - first_available_hour + fly_out_sunrise_hour
      fly_out_offset2 = fly_out_offset1 + fly_out_sunset_hour - @trip_input.eet_hour - fly_out_sunrise_hour
      for i in fly_out_offset1..fly_out_offset2
        hour  = Time.at(fly_out_dep_weather["hourly"][i]["dt"]).utc.to_datetime.hour
        icon  = fly_out_dep_weather["hourly"][i]["weather"][0]["icon"]
        desc = fly_out_dep_weather["hourly"][i]["weather"][0]["description"]
        buffer.push(hour, icon, desc)
        @fly_out_dep.push(buffer)
        buffer = []
      end
    end
    
    # case 3: current_time < sunrise
    #   Departure: today
    if first_available_hour < fly_out_sunrise_hour
      fly_out_offset1 = fly_out_sunrise_hour - first_available_hour
      fly_out_offset2 = fly_out_offset1 + fly_out_sunset_hour - fly_out_sunrise_hour - @trip_input.eet_hour
      for i in fly_out_offset1..fly_out_offset2
        hour  = Time.at(fly_out_dep_weather["hourly"][i]["dt"]).utc.to_datetime.hour
        icon  = fly_out_dep_weather["hourly"][i]["weather"][0]["icon"]
        desc = fly_out_dep_weather["hourly"][i]["weather"][0]["description"]
        buffer.push(hour, icon, desc)
        @fly_out_dep.push(buffer)
        buffer = []
      end
    end

    # ---------------------------------
    # --- Fly out arrival airport weather
    # ---------------------------------
    # Variable init
    @fly_out_arr = []
    fly_out_arr_weather = []
    icon = []
    hour = []
    desc = []
    buffer2 = [] 
    if @filtered_airports.count > 0
      for i in 0..@filtered_airports.count - 1
        api_call = RestClient.get 'https://api.openweathermap.org/data/3.0/onecall', {params: {lat:@filtered_airports[i].latitude, lon:@filtered_airports[i].longitude, appid:ENV["OPENWEATHERMAP_API"], exclude: "current, minutely", units: "metric"}}
        fly_out_arr_weather = JSON.parse(api_call)
        k = 0
        #TODO: Second offset needs to be checked if we fly on last possible departure hour
        for j in (fly_out_offset1 + @trip_input.eet_hour)..(fly_out_offset2 + @trip_input.eet_hour)
          hour[k] = Time.at(fly_out_arr_weather["hourly"][j]["dt"]).utc.to_datetime.hour 
          icon[k] = fly_out_arr_weather["hourly"][j]["weather"][0]["icon"]
          desc[k] = fly_out_arr_weather["hourly"][j]["weather"][0]["description"]
          buffer[k] = hour[k], icon[k], desc[k]
          buffer2.push(buffer[k])
          buffer = []
          k =+ 1
        end
        # We push all weather hours and info for a defined destination airport
        @fly_out_arr.push(buffer2)
        # We clean the buffer array
        buffer2 = []
      end
    end
    
    #---------------------------------
    # Fly in arrival airport weather
    # ---------------------------------
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

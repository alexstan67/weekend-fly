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
    
    # Departure Date
    current_date_time = Time.zone.now
    if current_date_time.day() == current_date_time.day()
      @departure_day = "Today"
    elsif
      ((current_date_time - current_date_time) / (3600*24)).round(0) == 1
      @departure_day = "Tomorrow"
    elsif
      ((current_date_time - current_date_time) / (3600*24)).round(0) == 2
      @departure_day = "After-tomorrow"
    else
      @departure_day = current_date_time.strftime("%A, %d %b") 
    end
    
    # Return Date
    current_date_time = Time.zone.now
    return_date_time = Time.zone.now + @trip_input.overnights.day
    if current_date_time.day() == return_date_time.day()
      @return_day = "Today"
    elsif
      ((return_date_time - current_date_time) / (3600*24)).round(0) == 1
      @return_day = "Tomorrow"
    elsif
      ((return_date_time - current_date_time) / (3600*24)).round(0)  == 2
      @return_day = "After-tomorrow"
    else
      @return_day = return_date_time.strftime("%A, %d %b") 
    end

  # --------------------------------------------------------------------
  # Openweather API
  # --------------------------------------------------------------------
  # Departure Airport weather
  api_call = RestClient.get 'https://api.openweathermap.org/data/3.0/onecall', {params: {lat:Airport.find_by(icao: @trip_input.dep_airport_icao).latitude, lon:Airport.find_by(icao: @trip_input.dep_airport_icao).longitude, appid:ENV["OPENWEATHERMAP_API"], exclude: "current, minutely", units: "metric"}}
  dep_weather = JSON.parse(api_call)

  # First weather info hour, index 0
  date_time  = dep_weather["hourly"][0]["dt"]

  # Departure weather from origin airport (will be hourly in openweathermap)
  @dep_icon0 = [ dep_weather["hourly"][0]["weather"][0]["icon"],  Time.at(date_time).utc.to_datetime.hour + 0, dep_weather["hourly"][0]["weather"][0]["description"] ] 
  @dep_icon1 = [ dep_weather["hourly"][1]["weather"][0]["icon"],  Time.at(date_time).utc.to_datetime.hour + 1, dep_weather["hourly"][1]["weather"][0]["description"] ]
  @dep_icon2 = [ dep_weather["hourly"][2]["weather"][0]["icon"],  Time.at(date_time).utc.to_datetime.hour + 2, dep_weather["hourly"][2]["weather"][0]["description"] ]
  @dep_icon3 = [ dep_weather["hourly"][3]["weather"][0]["icon"],  Time.at(date_time).utc.to_datetime.hour + 3, dep_weather["hourly"][3]["weather"][0]["description"] ]
  
  # Arrival weather from origin airport
  # Openweathermaps provides:
  #   - hourly: 48  hours  (max 1 overnight)
  #   - daily:  8   days   (more than 1 overnight)
  if @trip_input.overnights < 2
    @weather_mode = "hourly"
    if @trip_input.overnights == 0
      if current_date_time.hour <= 12
        # Departure today in the morning, so we display the weather in the afternoon
        shift = 12- current_date_time.hour
      else
        # Departure today in the afternon, so we still display weather in the atfernoon
        shift = current_date_time.hour - 12
      end
    @arr_icon0 = [ dep_weather["hourly"][shift + 0]["weather"][0]["icon"],  Time.at(date_time).utc.to_datetime.hour + shift + 0, dep_weather["hourly"][shift + 0]["weather"][0]["description"] ] 
    end
  
  end
  
  end
end

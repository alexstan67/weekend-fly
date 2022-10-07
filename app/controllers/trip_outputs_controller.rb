require "rest-client"
require "json"
require "normalize_country"

class TripOutputsController < ApplicationController
  def home
    # Variables init
    @errors = []
    @errors_label = []
    @errors_label[1] = "Flight back Impossible today with no overnights"
    @errors_label[2] = "No destination airport found"
    @limit = 15

    # We load logged in user last Trip_input data
    @trip_input = TripInput.where(user_id: current_user.id).order(id: :desc).first

    # We take the departure airport
    @airport = Airport.new
    @airport = Airport.where(icao: @trip_input.dep_airport_icao).order(id: :desc).first

    # SQL Distance calculation with 10% margin
    if @trip_input.distance_unit == "nm"
      distance_nm = @trip_input.distance
    else
      distance_nm = @trip_input.distance.to_f / 1.852
    end

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

    # SQL Filter on icao airports in result
    if @trip_input.icao_airport
      icao_filter = '^[A-Z]{4}$'
    else
      icao_filter = '\S'
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
          AND \
            airports.icao ~ ? \          
          ORDER BY \
             airports.country, airports.airport_type \
          LIMIT ?;"
    
    @filtered_airports = Airport.find_by_sql [sql, @airport.latitude, @airport.latitude, @airport.longitude, @airport.latitude, @airport.latitude, @airport.longitude, distance_nm + margin, @airport.latitude, @airport.latitude, @airport.longitude, distance_nm - margin, list_airport_type, list_country, icao_filter, @limit]

    # We check that we have at least 1 destination airport
    @errors.push(2) if @filtered_airports.count == 0


    # --------------------------------------------------------------------
    # --- Openweather API - If no errors raised
    # --------------------------------------------------------------------
    # Definitions:
    # ------------
    #   Fly Out = The day we fly from original airport to destination airport
    #   Fly In  = The day we fly from destination airport to original airport (Way back)
    

    # -------------------------------------------------
    # --- Fly out departure airport weather (Take Off)
    # -------------------------------------------------
    # We fist check that this api call is not currently stored in db for current pair airport_id / hour
    target_id = Airport.find_by(icao: @trip_input.dep_airport_icao).id

    if valid_weather_in_db?( target_id )
      # We take the json from the database
      fly_out_dep_weather = JSON.parse( OpenweatherCall.where(airport_id: target_id).last.json )
    else
      # Entry doesn't exist in DB, we proceed to the call
      api_call = RestClient.get 'https://api.openweathermap.org/data/3.0/onecall', {params: {lat:Airport.find_by( icao: @trip_input.dep_airport_icao ).latitude, lon:Airport.find_by( icao: @trip_input.dep_airport_icao ).longitude, appid:ENV["OPENWEATHERMAP_API"], exclude: "current, minutely", units: "metric"}}
      fly_out_dep_weather = JSON.parse( api_call )
      
      # We create a new entry in openweather_calls table
      create_weather_db_entry( target_id, api_call )
    end

    # Variable init
    @fly_out_dep = []
    @flight_data =  {}
    @flight_data[:day_return_offset] = @trip_input.overnights # by default the nbr of overnights
    
    # First available weather info hour, index 0
    @flight_data[:first_available_hour] = Time.at( fly_out_dep_weather["hourly"][0]["dt"] ).utc.to_datetime.hour

    # Fly-out sunrise and sunset info
    @flight_data[:fly_out_sunrise_hour] = Time.at( fly_out_dep_weather["daily"][0]["sunrise"] ).utc.to_datetime.hour
    @flight_data[:fly_out_sunset_hour]  = Time.at( fly_out_dep_weather["daily"][0]["sunset"] ).utc.to_datetime.hour
   
    # Departure Date exceptions
    if @flight_data[:first_available_hour]  > ( @flight_data[:fly_out_sunset_hour] - @trip_input.eet_hour )
      @flight_data[:day_departure_offset] = 1
    end
    
    # Return Date Exceptions
    if @trip_input.overnights == 0 && ( @flight_data[:first_available_hour] + (@trip_input.eet_hour * 2 ) >= @flight_data[:fly_out_sunset_hour])
      # Fly out and fly in same day not possible
      @flight_data[:day_return_offset] = 1
      @errors.push(1)
    end

    # case 1: sunrise < current_time < sunset
    # Departure: today
    if @flight_data[:first_available_hour] >= @flight_data[:fly_out_sunrise_hour] and \
       @flight_data[:first_available_hour] < ( @flight_data[:fly_out_sunset_hour] - @trip_input.eet_hour )
      fly_out_offset1 = 1 # We consider it's not possible to take off the same hour as you're searching for a flight
      fly_out_offset2 = fly_out_offset1 + @flight_data[:fly_out_sunset_hour] - @trip_input.eet_hour - @flight_data[:first_available_hour] - 1
    end
    
    # case 2: current_time > sunset
    # Departure: tomorrow
    if @flight_data[:first_available_hour] >= ( @flight_data[:fly_out_sunset_hour] - @trip_input.eet_hour )
      fly_out_offset1 = 24 - @flight_data[:first_available_hour] + @flight_data[:fly_out_sunrise_hour]
      fly_out_offset2 = fly_out_offset1 + @flight_data[:fly_out_sunset_hour] - @trip_input.eet_hour - @flight_data[:fly_out_sunrise_hour]
      @flight_data[:day_departure_offset] = 1
    end
    
    # case 3: current_time < sunrise
    # Departure: today
    if @flight_data[:first_available_hour] < @flight_data[:fly_out_sunrise_hour]
      fly_out_offset1 = @flight_data[:fly_out_sunrise_hour] - @flight_data[:first_available_hour]
      fly_out_offset2 = fly_out_offset1 + @flight_data[:fly_out_sunset_hour] - @flight_data[:fly_out_sunrise_hour] - @trip_input.eet_hour
    end

    # We adjust the flight-in day if flight out has now an offset
    @flight_data[:day_return_offset] += 1 if @flight_data[:day_departure_offset] == 1
    
    # We load the flight out departure weather
    @fly_out_dep = get_hourly_airport_weather( fly_out_offset1, fly_out_offset2, fly_out_dep_weather )
    
    # ---------------------------------------------
    # --- Fly out arrival airport weather (Landing)
    # ---------------------------------------------
    unless @errors.count > 0
      # We load the markers for the map
      @markers = []
      @filtered_airports.each do |airport|
        hash = { lat: airport.latitude, lon: airport.longitude, info_window: render_to_string(partial: "info_window", locals: {airport: airport}) }
        @markers << hash
      end

      # Variable init
      @fly_out_arr = []
      fly_out_arr_weather = []

      for i in 0..@filtered_airports.count - 1
        # We fist check that this api call is not currently stored in db for current pair airport_id / hour
        target_id = @filtered_airports[i].id

        if valid_weather_in_db?(target_id)
          # We take the json from the database
          fly_out_arr_weather = JSON.parse(OpenweatherCall.where(airport_id: target_id).last.json)
        else
          # Entry doesn't exist in DB, we proceed to the call
          api_call = RestClient.get 'https://api.openweathermap.org/data/3.0/onecall', {params: {lat:@filtered_airports[i].latitude, lon:@filtered_airports[i].longitude, appid:ENV["OPENWEATHERMAP_API"], exclude: "current, minutely", units: "metric"}}
          fly_out_arr_weather = JSON.parse(api_call)
      
          # We create a new entry in openweather_calls table
          create_weather_db_entry(target_id, api_call)
        end

        fly_out_offset3 = fly_out_offset1 + @trip_input.eet_hour
        fly_out_offset4 = fly_out_offset2 + @trip_input.eet_hour
        
        data = []
        data = get_hourly_airport_weather( fly_out_offset3, fly_out_offset4, fly_out_arr_weather)
        
        # We push all weather hours and info for a defined destination airport
        @fly_out_arr.push(data)
        
      end

      #------------------------------------------------
      # --- Fly in airport weather
      # -----------------------------------------------
      # Arrival weather from origin airport
      # Openweathermaps provides:
      #   - hourly: 48  hours  (max 1 overnight)
      #   - daily:  8   days   (more than 1 overnight)
      # We only use weather info stored in db - no API call
      
      # -----------------------------------------------------------
      # Departure weather loading
      # -----------------------------------------------------------
      
      # Variable init
      @fly_in_dep = []
      hourly_arr_weather = true # By defaut, weather is hourly
      
      if @flight_data[:day_return_offset] == 0    # today
        fly_in_offset1 = fly_out_offset1 + @trip_input.eet_hour
        fly_in_offset2 = fly_out_offset2 
        fly_in_offset3 = fly_out_offset1 + ( 2 * @trip_input.eet_hour )
        fly_in_offset4 = fly_out_offset2 + @trip_input.eet_hour
      elsif @flight_data[:day_return_offset] == 1 # tomorrow
        fly_in_offset1 = 24 - @flight_data[:first_available_hour] + @flight_data[:fly_out_sunrise_hour]
        fly_in_offset2 = fly_in_offset1 + (@flight_data[:fly_out_sunset_hour] - @flight_data[:fly_out_sunrise_hour]) - @trip_input.eet_hour
        fly_in_offset3 = fly_in_offset1 + @trip_input.eet_hour
        fly_in_offset4 = fly_in_offset2 + @trip_input.eet_hour
      else
        hourly_arr_weather = false
        # We don't have hourly weather after 48h, so we'll change to daily weather
      end
      
      for i in 0..@filtered_airports.count - 1
        fly_in_dep_weather = JSON.parse(OpenweatherCall.where(airport_id: @filtered_airports[i].id).last.json)
        
        if hourly_arr_weather
          data = []
          data = get_hourly_airport_weather( fly_in_offset1, fly_in_offset2, fly_in_dep_weather)
          # We push all weather hours and info for a defined destination airport
          #@fly_in_dep.push(data)
        else
          data = []
          data = get_daily_airport_weather( fly_in_dep_weather )
          #@fly_in_dep.push(data)
        end
        @fly_in_dep.push(data)
        logger.info @fly_in_dep
      end

      # -----------------------------------------------------------
      # Arrival weather loading
      # -----------------------------------------------------------
      
      # Variable init
      @fly_in_arr = []
      fly_in_arr_weather = fly_out_dep_weather # We retrieve the current known weather from departure airport

      # We load the flight in arrival weather
      if hourly_arr_weather
        @fly_in_arr = get_hourly_airport_weather( fly_in_offset3, fly_in_offset4, fly_in_arr_weather )
      else
        @fly_in_arr = get_daily_airport_weather( fly_in_arr_weather )
      end

      # --------------------------------------------------------------------
      # GLOBAL SCORE: Fly Out (By Aiport -> hour)
      # The global score is a gafor like system that gives an aeronautical indication if the fly
      # is safe in VFR conditions. See file weather_alerts.png on root directory.
      # --------------------------------------------------------------------
      @global_score_out = [] 
      buffer = []
      for i in 0..@filtered_airports.count - 1
        for h in 0..@fly_out_dep.count - 1
          global_score = [ @fly_out_arr[i][h][:partial_score], @fly_out_dep[h][:partial_score] ].max
          buffer.push(global_score)
        end
        @global_score_out.push(buffer)
        buffer = []
      end

      # --------------------------------------------------------------------
      # GLOBAL SCORE: Fly In (By Aiport -> hour)
      # --------------------------------------------------------------------
      @global_score_in = []
      buffer = []
      for i in 0..@filtered_airports.count - 1
        for h in 0..@fly_in_arr.count - 1
          global_score = [ @fly_in_dep[i][h][:partial_score], @fly_in_arr[h][:partial_score] ].max
          buffer.push(global_score)
        end
        @global_score_in.push(buffer)
        buffer = []
      end
    end    
  end

  private

  def valid_weather_in_db?(target_id)
    current_time = DateTime.now
    if OpenweatherCall.find_by(airport_id: target_id).nil?
      return false
    else
      weather_info = OpenweatherCall.where(airport_id: target_id).last
      if weather_info.created_at.today? && weather_info.created_at.utc.hour == current_time.utc.hour
        return true
      else
        return false
      end
    end  
  end

  def create_weather_db_entry(target_id, weather_json)
    # We create a new entry in openweather_calls table
    new_entry = OpenweatherCall.new
    new_entry.airport_id = target_id
    new_entry.json = weather_json
    new_entry.save
  end

  def get_visibility_score(visibility)
    if visibility <= 5000
      visi_score = 2
    elsif visibility > 1500 && visibility <  8000
      visi_score = 1
    else
      visi_score = 0
    end
    return visi_score
  end

  def get_ceiling_score(temp, dew_point)
    ceiling = ((temp.to_f - dew_point.to_f) * 400).to_i
    if ceiling < 500
      ceiling_score = 2
    elsif ceiling >= 500 && ceiling < 2000
      ceiling_score = 1
    else
      ceiling_score = 0
    end

    return ceiling_score
  end

  def get_hourly_airport_weather(offset1, offset2, weather_json)
    airport_weather = []
    for i in offset1..offset2
      visibility =              weather_json["hourly"][i]["visibility"]
      temp =                    weather_json["hourly"][i]["temp"]
      dew_point =               weather_json["hourly"][i]["dew_point"]

      hash = {}
      hash[:time_unit] =        "#{Time.at( weather_json["hourly"][i]["dt"] ).utc.to_datetime.hour}h"
      hash[:icon] =             weather_json["hourly"][i]["weather"][0]["icon"]
      hash[:description] =      weather_json["hourly"][i]["weather"][0]["description"]
      hash[:visibility_score] = get_visibility_score( visibility.to_i ) 
      hash[:ceiling_score] =    get_ceiling_score( temp.to_i, dew_point.to_i )
      hash[:partial_score] =    [ hash[:visibility_score], hash[:ceiling_score] ].max

      airport_weather.push(hash)

    end
    
    return airport_weather
  end

  def get_daily_airport_weather(weather_json)
    airport_weather = []

    hash = {}

    hash[:date] =           Time.at( weather_json["daily"][@flight_data[:day_return_offset]]["dt"] ).utc.to_datetime
    hash[:time_unit] =      "#{hash[:date].day}/#{hash[:date].month}"
    hash[:icon] =           weather_json["daily"][@flight_data[:day_return_offset]]["weather"][0]["icon"]
    hash[:description] =    weather_json["daily"][@flight_data[:day_return_offset]]["weather"][0]["description"]
    hash[:visi_score] =     0
    hash[:ceiling_score] =  0
    hash[:partial_score] =  9 # Info not available for daily json

    airport_weather.push(hash)

  end

end

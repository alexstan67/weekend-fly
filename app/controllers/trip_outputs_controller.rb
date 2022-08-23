require_relative '../../lib/assets/ruby_haversine'
require "normalize_country"

class TripOutputsController < ApplicationController
  def index
    # We load logged in user last Trip_input data
    @trip_input = TripInput.where(user_id: current_user.id).order(id: :desc).first

    # We take the departure airport
    @airport = Airport.new
    @airport = Airport.where(icao: @trip_input.dep_airport_icao).order(id: :desc).first

    # Distance calculation by SQL
    distance_nm = @trip_input.distance_nm
    margin = 0.1 * distance_nm

    # Filter on airport_type
    list_airport_type = []
    list_airport_type.push("small_airport") if @trip_input.small_airport
    list_airport_type.push("medium_airport") if @trip_input.medium_airport
    list_airport_type.push("large_airport") if @trip_input.large_airport

    sql = "SELECT \
          (((acos(sin(( ? *pi()/180)) * sin((latitude*pi()/180)) + cos(( ? *pi()/180)) \
          * cos((latitude*pi()/180)) * cos((( ? - longitude)*pi()/180)))) * 180/pi()) \
          * 60 ) as distance, * \
          FROM \
            airports \
          WHERE \
          (((acos(sin(( ? *pi()/180)) * sin((latitude*pi()/180)) + cos(( ? *pi()/180)) \
          * cos((latitude*pi()/180)) * cos((( ? - longitude)*pi()/180)))) * 180/pi()) \
          * 60) <= ? AND \
          (((acos(sin(( ? *pi()/180)) * sin((latitude*pi()/180)) + cos(( ? *pi()/180)) \
          * cos((latitude*pi()/180)) * cos((( ? - longitude)*pi()/180)))) * 180/pi()) \
          * 60) >= ? AND \
          airport_type in ( ? ) \
          order by airports.country, airports.airport_type;"


    @result = Airport.find_by_sql [sql, @airport.latitude, @airport.latitude, @airport.longitude, @airport.latitude, @airport.latitude, @airport.longitude, distance_nm + margin, @airport.latitude, @airport.latitude, @airport.longitude, distance_nm - margin, list_airport_type]
     
    # National / International flight filtering
    origin_country = Airport.find_by(icao: @trip_input.dep_airport_icao).country
    #@result.each |airport| do
      
    #end


  end
end

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

    sql = "SELECT \
          (((acos(sin(( ? *pi()/180)) * sin((latitude*pi()/180)) + cos(( ? *pi()/180)) \
          * cos((latitude*pi()/180)) * cos((( ? - longitude)*pi()/180)))) * 180/pi()) \
          * 60 ) as distance, * \
          FROM \
            airports \
          WHERE \
          (((acos(sin(( ? *pi()/180)) * sin((latitude*pi()/180)) + cos(( ? *pi()/180)) \
          * cos((latitude*pi()/180)) * cos((( ? - longitude)*pi()/180)))) * 180/pi()) \
          * 60) <= ? AND
          (((acos(sin(( ? *pi()/180)) * sin((latitude*pi()/180)) + cos(( ? *pi()/180)) \
          * cos((latitude*pi()/180)) * cos((( ? - longitude)*pi()/180)))) * 180/pi()) \
          * 60) >= ? order by airports.country, airports.airport_type;"

    @result = Airport.find_by_sql [sql, @airport.latitude, @airport.latitude, @airport.longitude, @airport.latitude, @airport.latitude, @airport.longitude, distance_nm + margin, @airport.latitude, @airport.latitude, @airport.longitude, distance_nm - margin]

  end
end

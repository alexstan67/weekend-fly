require 'csv'

namespace :import do

  desc "Import airports from csv file"
  task airports: :environment do
    filepath = "airports.csv"
    imported_countries = [ "Italy", "Luxembourg", "Czech Republic", "Sweden", "United Kingdom", "Ireland", "Germany", "Finland", "Slovenia", "Greece", "France", "Estonia", "Slovakia", "Iceland", "Denmark", "Switzerland", "Hungary", "Norway", "Netherlands", "Romania", "Austria", "Serbia", "Lithuania", "Bulgaria", "Spain", "Croatia", "Belgium", "Poland" ]
    counter = 0
    CSV.foreach(filepath) do |row|
      id, name, city, country, iata, icao, latitude, longitude, altitude, timezone, dst, tz, type, source = row
      if imported_countries.include?(country)
        airport = Airport.create(icao: icao, name: name, city: city, country: country, iata: iata, latitude: latitude, longitude: longitude, altitude: altitude, dst: dst)
        puts "#{id} - #{icao} - #{airport.errors.full_messages.join(",")}" if airport.errors.any?
        counter += 1 if airport.persisted?
      end
    end
    puts "Imported #{counter} aiports!"
  end
end

# select country, count(country) from airports group by country order by country;

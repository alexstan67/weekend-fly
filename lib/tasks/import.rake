require 'csv'

namespace :import do

  desc "Import airports from old csv file"
  task airports_old: :environment do
    filepath = "airports_old.csv"
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

# select country, count(country) from airports group by country order by country;
  desc "Import airports from csv file"
  task airports: :environment do
    filepath = "airports.csv"
    imported_countries = [ "IT", "LU", "CZ", "SE", "GB", "IE", "DE", "FI", "SI", "GR", "FR", "EE", "SK", "IS", "DK", "CH", "HU", "NO", "NL", "RO", "AT", "RS", "LT", "BG", "ES", "HR", "BE", "PL" ]
    counter = 0
    CSV.foreach(filepath, headers: :first_row) do |row|
      if imported_countries.include?(row['iso_country']) && !["closed","heliport","balloonport","seaplane_base"].include?(row['type'])
        airport = Airport.create(icao: row['ident'], name: row['name'], city: row['minicipality'], country: row['iso_country'], iata: row['iata_code'], latitude: row['latitude_deg'], longitude: row['longitude_deg'], altitude: row['elevation'], airport_type: row['type'], continent: row['continent'], url: row['home_link'], local_code: row['local_code'])
        puts "#{id} - #{ident} - #{airport.errors.full_messages.join(",")}" if airport.errors.any?
        counter += 1 if airport.persisted?
      end
    end
    puts "Imported #{counter} airports!"
  end
  
end

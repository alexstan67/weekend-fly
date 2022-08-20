require 'csv'

namespace :import do
  # -------------- AIRPORTS OLD -----------------
  # ---------------------------------------------
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

  # ---------------- AIRPORTS -------------------
  # ---------------------------------------------
  desc "Import airports from csv file"
  task airports: :environment do
    puts "Deleting airports entries..."
    Airport.destroy_all
    filepath = "airports.csv"
    puts "Reading #{filepath}..."
    counter_rejected = 0
    counter = 0
    CSV.foreach(filepath, headers: :first_row) do |row|
      airport = Airport.create(icao: row['ident'], name: row['name'], city: row['municipality'], country: row['iso_country'], iata: row['iata_code'], latitude: row['latitude_deg'], longitude: row['longitude_deg'], altitude: row['elevation'], airport_type: row['type'], continent: row['continent'], url: row['home_link'], local_code: row['local_code'])
      airport.persisted? ? counter += 1 : counter_rejected += 1
    end
    puts "Imported #{counter} / #{counter + counter_rejected} airports!"
  end

  # ---------------- COUNTRIES ------------------
  # ---------------------------------------------
  desc "Import countries from csv file"
  task countries: :environment do
    puts "Deleting countries entries..."
    Country.destroy_all
    filepath = "iso-3166-countries-slim2.csv"
    puts "Reading #{filepath}..."
    counter = 0
    CSV.foreach(filepath, headers: :first_row) do |row|
      country = Country.create(name: row['name'], alpha2: row['alpha-2'], country_code: row['country-code'])
      puts "#{name} - #{airport.errors.full_messages.join(",")}" if country.errors.any?
      counter += 1 if country.persisted?
    end
    puts "Imported #{counter} countries!"
  end
end


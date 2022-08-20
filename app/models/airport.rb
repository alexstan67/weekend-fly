class Airport < ApplicationRecord
  #validates :icao, presence: true, format: { with: /[a-zA-Z]{4}/, message: "Only valid ICAO Code, example \"ELLX\"" }
  #ACCEPTED_COUNTRIES = [ "IT", "LU", "CZ", "SE", "GB", "IE", "DE", "FI", "SI", "GR", "FR", "EE", "SK", "IS", "DK", "CH", "HU", "NO", "NL", "RO", "AT", "RS", "LT", "BG", "ES", "HR", "BE", "PL" ].freeze
  ACCEPTED_COUNTRIES = [ "LU", "DE", "FR" ].freeze
  ACCEPTED_AIRPORT_TYPES = [ "small_airport", "medium_airport", "large_airport" ].freeze
  validates :icao, presence: true
  validates :icao, format: { without: /ET[A-Z]{2}/, message: "No German military airbase" }
  validates :icao, format: { without: /(Air Base)/, message: "No French military airbase" }
  validates :continent, presence: true, length: { maximum: 2 }
  validates :country, presence: true, length: { maximum: 2 }, inclusion: { in: ACCEPTED_COUNTRIES }
  validates :airport_type, presence: true, inclusion: { in: ACCEPTED_AIRPORT_TYPES }
end

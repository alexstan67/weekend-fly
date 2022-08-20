class TripInput < ApplicationRecord
  FLIGHTBACK_SLOTS = ['AM','PM'].freeze
  VALID_ICAO_LIST = Airport.find_by_sql("SELECT icao FROM airports").freeze

  VALID_ICAO = []
  VALID_ICAO_LIST.each do |a|
    VALID_ICAO <<  a.icao
  end

  belongs_to :user
  validates :dep_airport_icao, presence: true, inclusion: { in: VALID_ICAO }
  validates :dep_in_hour, presence: true, numericality: { only_integer: true, less_than_or_equal_to: 10 }
  validates :distance_nm, presence: true, length: { maximum: 3 }, numericality: { only_integer: true, greater_than: 0 }
  validates :eet_hour, presence: true, length: { maximum: 1 }, numericality: true
  validates :average_gs_kts, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :overnights, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :flight_back, presence: true, inclusion: { in: FLIGHTBACK_SLOTS }
  validates_inclusion_of :small_airport, in: [true, false]
  validates_inclusion_of :medium_airport, in: [true, false]
  validates_inclusion_of :large_airport, in: [true, false]
  validates_inclusion_of :international_flight, in: [true, false]
end

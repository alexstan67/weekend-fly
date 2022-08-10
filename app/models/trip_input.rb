class TripInput < ApplicationRecord
  belongs_to :user
  validates :dep_airport_icao, presence: true #TODO: callback to check DB existance
  validates :dep_in_hour, presence: true, numericality: { only_integer: true, less_than_or_equal_to: 10}
  validates :distance_nm, presence: true, length: { maximum: 3 }, numericality: { only_integer: true, greater_than: 0 }
  validates :eet_min, presence: true, length: {maximum: 3 }, numericality: { only_integer: true, greater_than: 30 }
  validates :average_gs_kts, presence: true, numericality: { only_integer: true, greater_than: 0 }
end

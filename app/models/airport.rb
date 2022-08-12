class Airport < ApplicationRecord
  #validates :icao, presence: true, format: { with: /[a-zA-Z]{4}/, message: "Only valid ICAO Code, example \"ELLX\"" }
  validates :icao, presence: true
  validates :continent, presence: true, length: { maximum: 2 }
  validates :country, presence: true, length: { maximum: 2 }
end

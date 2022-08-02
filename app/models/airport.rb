class Airport < ApplicationRecord
  validates :icao, presence: true, format: { with: /[a-zA-Z]{4}/, message: "Only valid ICAO Code, example \"ELLX\"" }
end

class Country < ApplicationRecord
  validates :name, presence: true
  validates :alpha2, presence: true
  validates :country_code, presence: true
end

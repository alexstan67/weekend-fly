class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  CATEGORIES = ['km', 'nm'].freeze
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable, :lockable

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :homebase, presence: true, format: { with: /[a-zA-Z]{4}/, message: "Only valid ICAO Code, example \"ELLX\"" }
  validates :distance_unit, inclusion: CATEGORIES
end

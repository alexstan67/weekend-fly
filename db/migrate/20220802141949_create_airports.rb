class CreateAirports < ActiveRecord::Migration[7.0]
  def change
    create_table :airports do |t|
      t.string :icao
      t.string :name
      t.string :city
      t.string :country
      t.string :iata
      t.float :latitude
      t.float :longitude
      t.integer :altitude
      t.string :dst

      t.timestamps
    end
  end
end

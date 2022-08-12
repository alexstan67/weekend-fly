class CreateTripInputs < ActiveRecord::Migration[7.0]
  def change
    create_table :trip_inputs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :dep_airport_icao, null: false
      t.integer :dep_in_hour, null: false
      t.integer :distance_nm, null: false
      t.integer :eet_min, null: false
      t.integer :average_gs_kts, null: false

      t.timestamps
    end
  end
end

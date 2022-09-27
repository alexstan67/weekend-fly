class AddIcaoBooleanToTripInput < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_inputs, :icao_airport, :boolean, null: false, default: false
  end
end

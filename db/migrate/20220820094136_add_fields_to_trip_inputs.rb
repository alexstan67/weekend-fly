class AddFieldsToTripInputs < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_inputs, :small_airport, :boolean, default: "true"
    add_column :trip_inputs, :medium_airport, :boolean, default: "true"
    add_column :trip_inputs, :large_airport, :boolean, default: "false"
    add_column :trip_inputs, :international_flight, :boolean, default: "false"
  end
end

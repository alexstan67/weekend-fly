class RemoveFlightBackFromTripInputs < ActiveRecord::Migration[7.0]
  def change
    remove_column :trip_inputs, :flight_back, :string
    remove_column :trip_inputs, :dep_in_hour, :integer
  end
end

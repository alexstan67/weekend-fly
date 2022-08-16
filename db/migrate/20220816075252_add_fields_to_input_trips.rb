class AddFieldsToInputTrips < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_inputs, :overnights, :integer
    add_column :trip_inputs, :flight_back, :string
  end
end

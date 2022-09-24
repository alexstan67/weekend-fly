class ChangeColumnDistanceToTripInput < ActiveRecord::Migration[7.0]
  def change
    change_column :trip_inputs, :distance_nm, :decimal
  end
end

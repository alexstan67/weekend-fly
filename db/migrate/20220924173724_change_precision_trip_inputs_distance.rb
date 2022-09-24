class ChangePrecisionTripInputsDistance < ActiveRecord::Migration[7.0]
  def change
    change_column :trip_inputs, :distance_nm, :decimal, precision: 4, scale: 1
  end
end

class ChangeDistanceUnitTripInputs < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_inputs, :distance_unit, :string, null: false, default: "nm"
    rename_column :trip_inputs, :distance_nm, :distance
  end
end

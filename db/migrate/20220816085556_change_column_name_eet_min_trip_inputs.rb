class ChangeColumnNameEetMinTripInputs < ActiveRecord::Migration[7.0]
  def change
    rename_column :trip_inputs, :eet_min, :eet_hour
  end
end

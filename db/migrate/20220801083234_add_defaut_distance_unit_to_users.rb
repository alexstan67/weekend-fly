class AddDefautDistanceUnitToUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :distance_unit, "km"
  end
end

class RemoveDistanceUnitFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :distance_unit, :string
  end
end

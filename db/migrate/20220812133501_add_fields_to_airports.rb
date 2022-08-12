class AddFieldsToAirports < ActiveRecord::Migration[7.0]
  def change
    add_column :airports, :airport_type, :string
    add_column :airports, :continent, :string
    add_column :airports, :url, :string
    add_column :airports, :local_code, :string
  end
end

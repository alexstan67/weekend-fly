class CreateOpenweatherCalls < ActiveRecord::Migration[7.0]
  def change
    create_table :openweather_calls do |t|
      t.integer :airport_id
      t.text :json

      t.timestamps
    end
  end
end

class RemoveHomebaseToUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :homebase, :string
  end
end

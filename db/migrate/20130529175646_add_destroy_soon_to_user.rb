class AddDestroySoonToUser < ActiveRecord::Migration
  def change
    add_column :users, :destroy_soon, :boolean
    add_index :users, :destroy_soon
  end
end

class AddMyActivityUser < ActiveRecord::Migration
   def self.up
    add_column :users, :my_activity, :boolean, :default => true 
  end

  def self.down
    remove_column :users, :my_activity
  end
end

class AddOwnerToSchool < ActiveRecord::Migration
  def self.up
    add_column :schools, :owner, :integer, :null => false
  end
  
  def self.down
    remove_column :schools, :owner
  end
end

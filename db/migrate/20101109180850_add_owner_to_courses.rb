class AddOwnerToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :owner, :integer, :null => false

  end

  def self.down
    remove_column :courses, :owner
  end
end

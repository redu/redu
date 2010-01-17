class AddMainResourceToCourse < ActiveRecord::Migration
  def self.up
    add_column :courses, :main_resource_id, :integer
  end

  def self.down
    remove_column :courses, :main_resource_id
  end
end

class RemoveMainResourceFromCourse < ActiveRecord::Migration
  def self.up
    remove_column :courses, :main_resource_id
  end

  def self.down
    add_column :courses, :main_resource_id, :integer
  end
end

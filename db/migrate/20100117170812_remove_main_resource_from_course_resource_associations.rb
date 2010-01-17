class RemoveMainResourceFromCourseResourceAssociations < ActiveRecord::Migration
  def self.up
    remove_column :course_resource_associations, :main_resource
  end

  def self.down
    add_column :course_resource_associations, :main_resource, :boolean, {:default => false}
  end
end

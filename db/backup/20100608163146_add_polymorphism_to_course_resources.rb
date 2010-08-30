class AddPolymorphismToCourseResources < ActiveRecord::Migration
  def self.up
    add_column :course_resources, :attachable_id, :integer
    add_column :course_resources, :attachable_type, :string
    remove_column :course_resources, :course_id
  end

  def self.down
  end
end

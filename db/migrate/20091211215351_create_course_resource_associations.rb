class CreateCourseResourceAssociations < ActiveRecord::Migration
  def self.up
    create_table :course_resource_associations do |t|
      t.integer :course_id
      t.integer :resource_id
      t.boolean :main_resource

      t.timestamps
    end
  end

  def self.down
    drop_table :course_resource_associations
  end
end

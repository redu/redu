class CoursesResources < ActiveRecord::Migration
  def self.up
     create_table :courses_resources, :id => false do |t|
      t.integer :course_id
      t.integer :resource_id
    end
  end

  def self.down
     drop_table :courses_resources
  end
end

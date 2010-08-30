class CreateUserCourseAssociations < ActiveRecord::Migration
  def self.up
    create_table :user_course_associations do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :user_course_associations
  end
end

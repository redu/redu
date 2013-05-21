# -*- encoding : utf-8 -*-
class CreateUserCourseAssociations < ActiveRecord::Migration
  def self.up
    create_table :user_course_associations do |t|
      t.integer :user_id
      t.integer :course_id
      t.integer :role_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_course_associations
  end
end

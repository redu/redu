# -*- encoding : utf-8 -*-
class AddIndexToUserCourseAssociation < ActiveRecord::Migration
  def self.up
    add_index :user_course_associations, ["state"]
    add_index :user_course_associations, ["role"]
    add_index :user_course_associations, ["role", "state"]
  end

  def self.down
    remove_index :user_course_associations, :state
    remove_index :user_course_associations, :role
    remove_index :user_course_associations, :column => [:role, :state]
  end
end

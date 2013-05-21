# -*- encoding : utf-8 -*-
class AddStateToUserCourseAssociations < ActiveRecord::Migration
  def self.up
    add_column :user_course_associations, :state, :string
  end

  def self.down
    remove_column :user_course_associations, :state
  end
end

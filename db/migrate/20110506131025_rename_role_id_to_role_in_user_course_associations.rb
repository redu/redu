# -*- encoding : utf-8 -*-
class RenameRoleIdToRoleInUserCourseAssociations < ActiveRecord::Migration
  def self.up
    rename_column :user_course_associations, :role_id, :role
  end

  def self.down
    rename_column :user_course_associations, :role, :role_id
  end
end

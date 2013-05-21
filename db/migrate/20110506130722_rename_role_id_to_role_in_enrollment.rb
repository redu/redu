# -*- encoding : utf-8 -*-
class RenameRoleIdToRoleInEnrollment < ActiveRecord::Migration
  def self.up
    rename_column :enrollments, :role_id, :role
  end

  def self.down
    rename_column :enrollments, :role, :role_id
  end
end

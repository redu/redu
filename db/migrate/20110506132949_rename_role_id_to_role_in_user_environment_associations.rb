# -*- encoding : utf-8 -*-
class RenameRoleIdToRoleInUserEnvironmentAssociations < ActiveRecord::Migration
  def self.up
    rename_column :user_environment_associations, :role_id, :role
  end

  def self.down
    rename_column :user_environment_associations, :role, :role_id
  end
end

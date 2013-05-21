# -*- encoding : utf-8 -*-
class ChangeRoleIdToRoleOnUserSpaceAssociations < ActiveRecord::Migration
  def self.up
    rename_column :user_space_associations, :role_id, :role
  end

  def self.down
    rename_column :user_space_associations, :role, :role_id
  end
end

# -*- encoding : utf-8 -*-
class RenameRoleIdToRoleInUsers < ActiveRecord::Migration
  def self.up
    rename_column :users, :role_id, :role
  end

  def self.down
    rename_column :users, :role, :role_id
  end
end

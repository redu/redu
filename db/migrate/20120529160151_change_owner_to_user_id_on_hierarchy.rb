# -*- encoding : utf-8 -*-
class ChangeOwnerToUserIdOnHierarchy < ActiveRecord::Migration
  def self.up
    rename_column :courses, :owner, :user_id
    rename_column :environments, :owner, :user_id
    rename_column :lectures, :owner, :user_id
    rename_column :spaces, :owner, :user_id
  end

  def self.down
    rename_column :courses, :user_id, :owner
    rename_column :environments, :user_id, :owner
    rename_column :lectures, :user_id, :owner
    rename_column :spaces, :user_id, :owner
  end
end

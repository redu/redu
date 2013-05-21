# -*- encoding : utf-8 -*-
class RemoveRoleIdFromUserEnvironmentAssociations < ActiveRecord::Migration
  def self.up
    remove_column :user_environment_associations, :role_id
  end

  def self.down
    add_column :user_environment_associations, :role_id, :integer
  end
end

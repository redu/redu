# -*- encoding : utf-8 -*-
class AddRoleIdToUserEnvironmentAssociations < ActiveRecord::Migration
  def self.up
    add_column :user_environment_associations, :role_id, :integer
  end

  def self.down
    remove_column :user_environment_associations, :role_id
  end
end

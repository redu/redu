# -*- encoding : utf-8 -*-
class ChangeIndexToUniqueOnUserEnvironmentAssociations < ActiveRecord::Migration
  def self.up
    remove_index :user_environment_associations,
      :name => :uea_user_id_environment_id
    add_index :user_environment_associations, [:user_id, :environment_id],
      :unique => true, :name => :uea_user_id_environment_id
  end

  def self.down
    remove_index :user_environment_associations,
      :name => :uea_user_id_environment_id
    add_index :user_environment_associations, [:user_id, :environment_id],
      :name => :uea_user_id_environment_id
  end
end

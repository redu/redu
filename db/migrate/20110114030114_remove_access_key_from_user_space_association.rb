# -*- encoding : utf-8 -*-
class RemoveAccessKeyFromUserSpaceAssociation < ActiveRecord::Migration
  def self.up
    remove_column :user_space_associations, :access_key_id
  end

  def self.down
    add_column :user_space_associations, :access_key_id, :integer
  end
end

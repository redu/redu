# -*- encoding : utf-8 -*-
class RemoveStatusFromUserSpaceAssociation < ActiveRecord::Migration
  def self.up
    remove_column :user_space_associations, :status
  end

  def self.down
    add_column :user_space_associations, :status, :string
  end
end

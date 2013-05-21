# -*- encoding : utf-8 -*-
class ChangeDefaultRoleValueOnUserSpaceAssociation < ActiveRecord::Migration
  def self.up
    change_column_default :user_space_associations, :role, 2
  end

  def self.down
    change_column_default :user_space_associations, :role, 7
  end
end

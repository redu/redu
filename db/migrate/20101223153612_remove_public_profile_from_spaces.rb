# -*- encoding : utf-8 -*-
class RemovePublicProfileFromSpaces < ActiveRecord::Migration
  def self.up
    remove_column :spaces, :public_profile
  end

  def self.down
    add_column :spaces, :public_profile, :boolean
  end
end

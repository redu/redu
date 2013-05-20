# -*- encoding : utf-8 -*-
class AddExploredToUserSettings < ActiveRecord::Migration
  def self.up
    add_column :user_settings, :explored, :text
  end

  def self.down
    remove_column :user_settings, :explored
  end
end

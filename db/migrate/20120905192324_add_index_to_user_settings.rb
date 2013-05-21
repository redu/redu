# -*- encoding : utf-8 -*-
class AddIndexToUserSettings < ActiveRecord::Migration
  def self.up
    add_index :user_settings, :user_id
  end

  def self.down
    remove_index :user_settings, :user_id
  end
end

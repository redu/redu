# -*- encoding : utf-8 -*-
class AddFriendsCountToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :friends_count, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :users, :friends_count
  end
end

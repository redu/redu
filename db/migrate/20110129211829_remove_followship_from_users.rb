# -*- encoding : utf-8 -*-
class RemoveFollowshipFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :followers_count
    remove_column :users, :follows_count
  end

  def self.down
    add_column :users, :follows_count, :integer
    add_column :users, :followers_count, :integer
  end
end

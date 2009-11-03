class AddCounterCacheForFollowersAndFollows < ActiveRecord::Migration
  def self.up
    add_column :users, :followers_count, :integer, :default => 0
    User.reset_column_information
    User.find(:all).each do |c|
      c.update_attribute :followers_count, c.followers.length
    end
    
    add_column :users, :follows_count, :integer, :default => 0
    User.reset_column_information
    User.find(:all).each do |c|
      c.update_attribute :follows_count, c.follows.length
    end
  end
  def self.down
    remove_column :users, :followers_count
    remove_column :users, :follows_count
  end
end

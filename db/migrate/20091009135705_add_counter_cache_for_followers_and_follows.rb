class AddCounterCacheForFollowersAndFollows < ActiveRecord::Migration
  def self.up
    add_column :users, :followers_count, :integer, :default => 0
    
    add_column :users, :follows_count, :integer, :default => 0
  
  end
  def self.down
    remove_column :users, :followers_count
    remove_column :users, :follows_count
  end
end

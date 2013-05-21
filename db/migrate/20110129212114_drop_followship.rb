# -*- encoding : utf-8 -*-
class DropFollowship < ActiveRecord::Migration
  def self.up
    drop_table :followship
  end

  def self.down  
    create_table "followship", :id => false, :force => true do |t|
      t.integer "followed_by_id"
      t.integer "follows_id"
    end
  end
end

# -*- encoding : utf-8 -*-
class AddSpaceIdToSbPosts < ActiveRecord::Migration
  def self.up
    add_column :sb_posts, :space_id, :integer
  end

  def self.down
    remove_column :sb_posts, :space_id
  end
end

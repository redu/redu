# -*- encoding : utf-8 -*-
class AddSpaceIdToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :space_id, :integer
  end

  def self.down
    remove_column :topics, :space_id
  end
end

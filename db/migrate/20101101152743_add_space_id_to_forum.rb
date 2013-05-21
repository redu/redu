# -*- encoding : utf-8 -*-
class AddSpaceIdToForum < ActiveRecord::Migration
  def self.up
    add_column :forums, :space_id, :integer
  end

  def self.down
    remove_column :forums, :space_id
  end
end

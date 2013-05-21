# -*- encoding : utf-8 -*-
class RemoveSpaceIdFromBulletins < ActiveRecord::Migration
  def self.up
    remove_column :bulletins, :space_id
  end

  def self.down
    add_column :bulletins, :space_id, :integer
  end
end

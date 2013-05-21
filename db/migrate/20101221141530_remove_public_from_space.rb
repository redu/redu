# -*- encoding : utf-8 -*-
class RemovePublicFromSpace < ActiveRecord::Migration
  def self.up
    remove_column :spaces, :public
  end

  def self.down
    add_column :spaces, :public, :boolean
  end
end

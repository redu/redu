# -*- encoding : utf-8 -*-
class RemovePublicFromEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :public
  end

  def self.down
    add_column :events, :public, :boolean
  end
end

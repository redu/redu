# -*- encoding : utf-8 -*-
class RemoveTagLineFromEvent < ActiveRecord::Migration
  def self.up
    remove_column :events, :tagline
  end

  def self.down
    add_column :events, :tagline, :string
  end
end

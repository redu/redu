# -*- encoding : utf-8 -*-
class RemoveTagLineFromBulletin < ActiveRecord::Migration
  def self.up
    remove_column :bulletins, :tagline
  end

  def self.down
    add_column :bulletins, :tagline, :string
  end
end

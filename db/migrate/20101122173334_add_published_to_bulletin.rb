# -*- encoding : utf-8 -*-
class AddPublishedToBulletin < ActiveRecord::Migration
  def self.up
    add_column :bulletins, :published, :boolean, :default => true
  end

  def self.down
    remove_column :bulletins, :published
  end
end

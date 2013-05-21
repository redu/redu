# -*- encoding : utf-8 -*-
class RemovePublishedFromBulletin < ActiveRecord::Migration
  def self.up
    remove_column :bulletins, :published
  end

  def self.down
    add_column :bulletins, :published, :boolean, :default => true
  end
end

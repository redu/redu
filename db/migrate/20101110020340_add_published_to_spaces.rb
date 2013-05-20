# -*- encoding : utf-8 -*-
class AddPublishedToSpaces < ActiveRecord::Migration
  def self.up
    add_column :spaces, :published, :boolean, :default => false
  end

  def self.down
    remove_column :spaces, :published
  end
end

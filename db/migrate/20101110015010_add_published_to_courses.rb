# -*- encoding : utf-8 -*-
class AddPublishedToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :published, :boolean, :default => false
  end

  def self.down
    remove_column :courses, :published
  end
end

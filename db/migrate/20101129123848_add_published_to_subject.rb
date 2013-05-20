# -*- encoding : utf-8 -*-
class AddPublishedToSubject < ActiveRecord::Migration
  def self.up
    add_column :subjects, :published, :boolean, :default => false
  end

  def self.down
    remove_column :subjects, :published
  end
end

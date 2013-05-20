# -*- encoding : utf-8 -*-
class RemoveLecturesCountFromSpaces < ActiveRecord::Migration
  def self.up
    remove_column :spaces, :lectures_count
  end

  def self.down
    add_column :spaces, :lectures_count, :integer
  end
end

class RenameColumnPublishedToVisible < ActiveRecord::Migration
  def self.up
    rename_column :subjects, :published, :visible 
  end

  def self.down
    rename_column :subjects, :visible, :published 
  end
end

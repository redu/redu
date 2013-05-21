# -*- encoding : utf-8 -*-
class RenameFolderSchoolToSpace < ActiveRecord::Migration
  def self.up
    rename_column :folders, :school_id, :space_id
  end

  def self.down
    rename_column :folders, :space_id, :school_id
  end
end

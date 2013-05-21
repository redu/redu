# -*- encoding : utf-8 -*-
class RenameTitleColumnToNameInSubjects < ActiveRecord::Migration
  def self.up
    rename_column :subjects, :title, :name
  end

  def self.down
    rename_column :subjects, :name, :title
  end
end

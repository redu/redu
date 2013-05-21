# -*- encoding : utf-8 -*-
class CrateIsCloneInCourse < ActiveRecord::Migration
  def self.up
     add_column :courses, :is_clone, :boolean,  :default => false
     add_column :exams, :is_clone, :boolean,  :default => false
  end

  def self.down
    remove_column :courses, :is_clone
    remove_column :exams, :is_clone
  end
end

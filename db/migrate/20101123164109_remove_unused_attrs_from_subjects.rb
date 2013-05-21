# -*- encoding : utf-8 -*-
class RemoveUnusedAttrsFromSubjects < ActiveRecord::Migration
  def self.up
    remove_column :subjects, :simple_category_id
    remove_column :subjects, :start_time
    remove_column :subjects, :end_time
    remove_column :subjects, :limit
  end

  def self.down
    add_column :subjects, :limit, :integer
    add_column :subjects, :end_time, :date
    add_column :subjects, :start_time, :date
    add_column :subjects, :simple_category_id, :integer
  end
end

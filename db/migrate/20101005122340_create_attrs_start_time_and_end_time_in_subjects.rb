# -*- encoding : utf-8 -*-
class CreateAttrsStartTimeAndEndTimeInSubjects < ActiveRecord::Migration
  def self.up
    add_column :subjects, :start_time, :date
    add_column :subjects, :end_time, :date
  end

  def self.down
    remove_column :subjects, :start_time
    remove_column :subjects, :end_time
  end
end

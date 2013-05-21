# -*- encoding : utf-8 -*-
class CourseStudentLimit < ActiveRecord::Migration
  def self.up
    add_column :subjects, :limit, :integer
  end

  def self.down
    remove_column :subjects, :limit
  end
end

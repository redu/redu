# -*- encoding : utf-8 -*-
class AddCourseIdToSpaces < ActiveRecord::Migration
  def self.up
    add_column :spaces, :course_id, :integer
  end

  def self.down
    remove_column :spaces, :course_id
  end
end

# -*- encoding : utf-8 -*-
class RenameAudiencesSpacesToAudiencesCourse < ActiveRecord::Migration
  def self.up
    rename_table :audiences_spaces, :audiences_courses
    rename_column :audiences_courses, :space_id, :course_id
  end

  def self.down
    rename_table :audiences_courses, :audiences_spaces
    rename_column :audiences_spaces, :course_id, :space_id
  end
end

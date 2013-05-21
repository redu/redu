# -*- encoding : utf-8 -*-
class AddStudentProfileToEnrollment < ActiveRecord::Migration
  def self.up
    add_column :student_profiles, :enrollment_id, :integer
  end

  def self.down
    remove_column :student_profiles, :enrollment_id
  end
end

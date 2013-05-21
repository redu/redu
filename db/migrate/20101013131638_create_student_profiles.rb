# -*- encoding : utf-8 -*-
class CreateStudentProfiles < ActiveRecord::Migration
  def self.up
    create_table :student_profiles do |t|
      t.integer :user_id
      t.integer :subject_id
      t.integer :course_subject_id
      t.integer :graduaded
      t.float :grade

      t.timestamps
    end
  end

  def self.down
    drop_table :student_profiles
  end
end

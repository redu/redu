# -*- encoding : utf-8 -*-
class RefactoringStudentProfile < ActiveRecord::Migration
  def self.up
    change_table :student_profiles do |t|
      t.references :asset
    end
    change_column :student_profiles, :graduaded, :boolean, :default => false
    change_column :student_profiles, :grade, :float, :default => 0.0
    remove_column :student_profiles, :course_subject_id
  end

  def self.down
    remove_column :student_profiles, :asset_id
    change_table :student_profiles do |t|
      t.integer :course_subject_id
    end
    change_column :student_profiles, :graduaded, :integer
    change_column :student_profiles, :grade, :float
  end
end

# -*- encoding : utf-8 -*-
class RenameCourseToLecture < ActiveRecord::Migration
  def self.up
    # Tables
    rename_table :courses, :lectures
    rename_table :course_subjects, :lecture_subjects

    # Attributes
    rename_column :acquisitions, :course_id, :lecture_id
    rename_column :annotations, :course_id, :lecture_id
    rename_column :lecture_subjects, :courseable_id, :lectureable_id
    rename_column :lecture_subjects, :courseable_type, :lectureable_type
    rename_column :lectures, :courseable_type, :lectureable_type
    rename_column :lectures, :courseable_id, :lectureable_id
    rename_column :spaces, :courses_count, :lectures_count
  end

  def self.down
    # Tables
    rename_table :lecture_subjects,:course_subjects
    rename_table :lectures, :courses

    # Attributes
    rename_column :acquisitions, :lecture_id,:course_id
    rename_column :annotations, :lecture_id, :course_id
    rename_column :lecture_subjects, :lectureable_id, :courseable_id
    rename_column :lecture_subjects, :lectureable_type, :courseable_type
    rename_column :lectures, :lectureable_type, :courseable_type
    rename_column :lectures, :lectureable_id, :courseable_id
    rename_column :spaces, :lectures_count, :courses_count
  end
end

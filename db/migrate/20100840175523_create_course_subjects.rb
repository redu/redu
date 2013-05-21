# -*- encoding : utf-8 -*-
class CreateCourseSubjects < ActiveRecord::Migration
  def self.up
    create_table :course_subjects do |t|
      t.integer :subject_id
      t.integer :position
      t.references :courseable, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :course_subjects
  end
end

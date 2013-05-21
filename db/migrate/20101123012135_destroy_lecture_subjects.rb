# -*- encoding : utf-8 -*-
class DestroyLectureSubjects < ActiveRecord::Migration
  def self.up
    drop_table :lecture_subjects
  end

  def self.down
    create_table :lecture_subjects do |t|
      t.integer :subject_id
      t.integer :position
      t.references :lectureable, :polymorphic => true
      t.timestamps
    end
  end
end

# -*- encoding : utf-8 -*-
class DestroyAudiencesSubjects < ActiveRecord::Migration
  def self.up
    drop_table :audiences_subjects
  end

  def self.down
    create_table :audiences_subjects,  :id => false do |t|
      t.integer :audience_id
      t.integer :subject_id
      t.timestamps
    end
  end
end

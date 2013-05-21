# -*- encoding : utf-8 -*-
class CreateAudiencesSubjectsTable < ActiveRecord::Migration
  def self.up
    create_table :audiences_subjects,  :id => false do |t|
      t.integer :audience_id
      t.integer :subject_id
      t.timestamps
    end
  end

  def self.down
    drop_table :audiences_subjects
  end
end

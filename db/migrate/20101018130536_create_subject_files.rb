# -*- encoding : utf-8 -*-
class CreateSubjectFiles < ActiveRecord::Migration
  def self.up
    create_table :subject_files do |t|
      t.integer :subject_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :subject_files
  end
end

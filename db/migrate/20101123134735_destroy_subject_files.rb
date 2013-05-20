# -*- encoding : utf-8 -*-
class DestroySubjectFiles < ActiveRecord::Migration
  def self.up
    drop_table :subject_files
  end

  def self.down
    create_table :subject_files do |t|
      t.integer :subject_id
      t.string :name
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at
      t.timestamps
    end
  end
end

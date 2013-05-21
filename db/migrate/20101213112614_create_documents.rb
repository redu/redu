# -*- encoding : utf-8 -*-
class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at
      t.integer :ipaper_id
      t.string :ipaper_access_key
      t.string :state
      t.boolean :published, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end

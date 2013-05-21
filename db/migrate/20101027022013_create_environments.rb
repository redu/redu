# -*- encoding : utf-8 -*-
class CreateEnvironments < ActiveRecord::Migration
  def self.up
    create_table :environments do |t|
      t.string :name
      t.text :description
      t.string :path
      t.string   :avatar_file_name
      t.string   :avatar_content_type
      t.integer  :avatar_file_size
      t.datetime :avatar_updated_at
      t.string :theme
      t.integer :owner, :null => false
      t.boolean :published, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :environments
  end
end

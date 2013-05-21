# -*- encoding : utf-8 -*-
class RemoveFieldsNotUsedFromLecture < ActiveRecord::Migration
  def self.up
    remove_column :lectures, :removed
    remove_column :lectures, :description
    remove_column :lectures, :published
    remove_column :lectures, :avatar_file_name
    remove_column :lectures, :avatar_content_type
    remove_column :lectures, :avatar_file_size
    remove_column :lectures, :avatar_updated_at
  end

  def self.down
    add_column :lectures, :removed
    add_column :lectures, :description
    add_column :lectures, :published
    add_column :lectures, :avatar_file_name
    add_column :lectures, :avatar_content_type
    add_column :lectures, :avatar_file_size
    add_column :lectures, :avatar_updated_at
  end
end

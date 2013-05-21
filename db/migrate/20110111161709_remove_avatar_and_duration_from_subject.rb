# -*- encoding : utf-8 -*-
class RemoveAvatarAndDurationFromSubject < ActiveRecord::Migration
  def self.up
    remove_column :subjects, :avatar_file_name
    remove_column :subjects, :avatar_content_type
    remove_column :subjects, :avatar_file_size
    remove_column :subjects, :avatar_updated_at
    remove_column :subjects, :duration
  end

  def self.down
    add_column :subjects, :duration, :integer
    add_column :subjects, :avatar_file_size, :integer
    add_column :subjects, :avatar_content_type, :string
    add_column :subjects, :avatar_file_name, :string
    add_column :subjects, :avatar_updated_at, :datetime
  end
end

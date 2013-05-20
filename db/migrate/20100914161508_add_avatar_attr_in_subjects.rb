# -*- encoding : utf-8 -*-
class AddAvatarAttrInSubjects < ActiveRecord::Migration
  def self.up
    add_column :subjects, :avatar_file_name, :string
    add_column :subjects, :avatar_content_type, :string
    add_column :subjects, :avatar_file_size, :integer
    add_column :subjects, :avatar_updated_at, :datetime
  end

  def self.down
    remove_column :subjects, :avatar_file_name
    remove_column :subjects, :avatar_content_type
    remove_column :subjects, :avatar_file_size
    remove_column :subjects, :avatar_updated_at
  end
end

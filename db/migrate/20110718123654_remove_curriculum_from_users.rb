# -*- encoding : utf-8 -*-
class RemoveCurriculumFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :curriculum_file_name
    remove_column :users, :curriculum_content_type
    remove_column :users, :curriculum_file_size
    remove_column :users, :curriculum_updated_at
  end

  def self.down
    add_column :users, :curriculum_file_name, :string
    add_column :users, :curriculum_content_type, :string
    add_column :users, :curriculum_file_size, :integer
    add_column :users, :curriculum_updated_at, :datetime
  end
end

# -*- encoding : utf-8 -*-
class AddOriginalMediaToSeminar < ActiveRecord::Migration
  def self.up
    add_column :seminars, :original_file_name,    :string
    add_column :seminars, :original_content_type, :string
    add_column :seminars, :original_file_size,    :integer
    add_column :seminars, :original_updated_at,   :datetime
  end

  def self.down
    remove_column :seminars, :original_file_name
    remove_column :seminars, :original_content_type
    remove_column :seminars, :original_file_size
    remove_column :seminars, :original_updated_at
  end
end

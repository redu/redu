class AddImageToQuestion < ActiveRecord::Migration
  def self.up
     add_column :questions, :image_file_name, :string # Original filename
    add_column :questions, :image_content_type, :string # Mime type
    add_column :questions, :image_file_size, :integer # File size in bytes
  end

  def self.down
    remove_column :questions, :image_file_name
    remove_column :questions, :image_content_type
    remove_column :questions, :image_file_size
  end
end

class AddPaperclipToMyFiles < ActiveRecord::Migration
  def self.up
    remove_column :myfiles, :filename
    remove_column :myfiles, :filesize
    remove_column :myfiles, :date_modified
    
    add_column :myfiles, :attachment_file_name, :string # Original filename
    add_column :myfiles, :attachment_content_type, :string # Mime type
    add_column :myfiles, :attachment_file_size, :integer # File size in bytes
    add_column :myfiles, :attachment_updated_at, :datetime # File size in bytes
  end

  def self.down
    remove_column :myfiles, :attachment_file_name
    remove_column :myfiles, :attachment_content_type
    remove_column :myfiles, :attachment_file_size
    remove_column :myfiles, :attachment_updated_at
    
     add_column :myfiles, :filename, :string # Original filename
    add_column :myfiles, :filesize, :integer # Mime type
    add_column :myfiles, :date_modified, :datetime # File size in bytes
  end
end

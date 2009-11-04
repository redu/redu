class AddPaperclipResources < ActiveRecord::Migration
  def self.up
     add_column :resources, :media_content_type, :string
     add_column :resources, :media_file_name, :string
     add_column :resources, :media_file_size, :integer
  end

  def self.down
    remove_column :resources, :media_content_type
    remove_column :resources, :media_file_name
    remove_column :resources, :media_file_size
  end
end

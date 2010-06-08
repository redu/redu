class RenameColsCourseResources < ActiveRecord::Migration
  def self.up
    rename_column :course_resources, :media_file_name, :attachment_file_name
    rename_column :course_resources, :media_file_size,:attachment_file_size
    rename_column :course_resources, :media_content_type, :attachment_content_type
    rename_column :course_resources, :media_updated_at, :attachment_updated_at

  end

  def self.down
  end
end

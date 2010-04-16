class CreateCourseResources < ActiveRecord::Migration
  def self.up
    create_table :course_resources do |t|
      t.integer :course_id
      t.string :name
      t.string :media_file_name
      t.integer :media_file_size
      t.string :media_content_type
      t.datetime :media_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :course_resources
  end
end

class CreateSeminars < ActiveRecord::Migration
  def self.up
    create_table :seminars do |t|
      t.string :media_file_name
      t.string :media_content_type
      t.integer :media_file_size
      t.time :media_updated_at
      
      t.string :external_resource
      t.string :external_resource_type
      
      t.integer :course_id
      t.timestamps
    end
  end

  def self.down
    drop_table :seminars
  end
end

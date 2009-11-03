class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string :source_content_type
      t.string :source_file_name
      t.integer :source_file_size
      t.string :state
      t.string :title, :null => false
      t.text :description    
      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end
class CreateAnnotations < ActiveRecord::Migration
  def self.up
    create_table :annotations do |t|
      t.integer :user_id, :null => false
      t.integer :course_id, :null => false
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :annotations
  end
end

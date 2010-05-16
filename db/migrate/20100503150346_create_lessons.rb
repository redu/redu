class CreateLessons < ActiveRecord::Migration
  def self.up
    create_table :lessons do |t|
      t.string :title
      t.text :body
      t.integer :interactive_class_id
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :lessons
  end
end

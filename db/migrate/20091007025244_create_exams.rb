class CreateExams < ActiveRecord::Migration
  def self.up
    create_table :exams do |t|
      t.integer :author_id, :null => false
      t.string :name, :null => false
      t.text :description
      t.boolean :published, :default => 0
      t.integer :done_count, :default => 0
      t.float :total_correct, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :exams
  end
end

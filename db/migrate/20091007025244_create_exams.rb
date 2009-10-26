class CreateExams < ActiveRecord::Migration
  def self.up
    create_table :exams do |t|
      t.integer :author_id
      t.string :name
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

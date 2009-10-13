class CreateExams < ActiveRecord::Migration
  def self.up
    create_table :exams do |t|
      t.integer :author_id
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :exams
  end
end

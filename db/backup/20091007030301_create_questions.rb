class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.text :statement, :null => false
      t.integer :answer_id
      t.integer :author_id
      t.boolean :public, :default => 0
      t.text :justification
      t.integer :image_id

      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end

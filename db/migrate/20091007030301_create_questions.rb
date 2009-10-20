class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.text :statement, :null => false
      t.integer :answer_id, :null => false
      t.boolean :is_public, :default => 0
      t.text :justification
      t.integer :image_id
      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end

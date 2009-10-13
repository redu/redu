class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.text :statement
      t.integer :answer_id
      t.boolean :is_public, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end

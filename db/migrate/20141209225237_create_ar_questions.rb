class CreateArQuestions < ActiveRecord::Migration
  def self.up
    create_table :ar_questions do |t|
      t.references :exercise	
      t.text :statement
      t.text :explanation

      t.timestamps
    end
  end

  def self.down
    drop_table :ar_questions
  end
end

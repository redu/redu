class CreateQuestionExamAssociations < ActiveRecord::Migration
  def self.up
    create_table :question_exam_associations, :id => false do |t|
      t.integer :total_answers_count
      t.integer :correct_answers_count
      t.integer :question_id
      t.integer :exam_id
      t.timestamps
    end
  end

  def self.down
    drop_table :question_exam_associations
  end
end

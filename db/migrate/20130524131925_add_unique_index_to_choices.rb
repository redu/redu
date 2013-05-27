class AddUniqueIndexToChoices < ActiveRecord::Migration
  def change
    add_index :choices, [:user_id, :question_id], unique: true
  end
end

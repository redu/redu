class CreateArAnswers < ActiveRecord::Migration
  def change
    create_table :ar_answers do |t|
      t.references :user
  	  t.references :ar_question
  	  t.references :result
      t.text :texto
      t.decimal :rate

      t.timestamps
    end
  end
end

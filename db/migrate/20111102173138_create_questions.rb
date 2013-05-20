# -*- encoding : utf-8 -*-
class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.references :exercise
      t.text :statement
      t.text :explanation
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end

# -*- encoding : utf-8 -*-
class CreateChoices < ActiveRecord::Migration
  def self.up
    create_table :choices do |t|
      t.references :user
      t.boolean :correct, :default => false
      t.references :alternative
      t.references :result
      t.references :question

      t.timestamps
    end
  end

  def self.down
    drop_table :choices
  end
end

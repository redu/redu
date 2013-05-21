# -*- encoding : utf-8 -*-
class CreateAlternatives < ActiveRecord::Migration
  def self.up
    create_table :alternatives do |t|
      t.text :text
      t.references :question
      t.boolean :correct, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :alternatives
  end
end

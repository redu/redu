# -*- encoding : utf-8 -*-
class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table :subjects do |t|
      t.string :title
      t.text :description
      t.integer :user_id
      t.boolean :is_public
      t.integer :school_id
      t.timestamps
    end
  end

  def self.down
    drop_table :subjects
  end
end

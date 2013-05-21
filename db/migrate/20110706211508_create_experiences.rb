# -*- encoding : utf-8 -*-
class CreateExperiences < ActiveRecord::Migration
  def self.up
    create_table :experiences do |t|
      t.string :title
      t.string :company
      t.date :start_date
      t.date :end_date
      t.boolean :current, :default => false
      t.text :description
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :experiences
  end
end

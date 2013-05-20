# -*- encoding : utf-8 -*-
class CreateHigherEducations < ActiveRecord::Migration
  def self.up
    create_table :higher_educations do |t|
      t.string :kind
      t.string :institution
      t.date :start_year
      t.date :end_year
      t.text :description
      t.string :course
      t.string :research_area

      t.timestamps
    end
  end

  def self.down
    drop_table :higher_educations
  end
end

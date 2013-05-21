# -*- encoding : utf-8 -*-
class CreateHighSchools < ActiveRecord::Migration
  def self.up
    create_table :high_schools do |t|
      t.string :institution
      t.date :end_year
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :high_schools
  end
end

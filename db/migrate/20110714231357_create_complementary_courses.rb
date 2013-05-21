# -*- encoding : utf-8 -*-
class CreateComplementaryCourses < ActiveRecord::Migration
  def self.up
    create_table :complementary_courses do |t|
      t.string :course
      t.string :institution
      t.date :year
      t.integer :workload
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :complementary_courses
  end
end

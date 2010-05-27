class AddPriceToCoursesExams < ActiveRecord::Migration
  def self.up
    drop_table :course_prices
     add_column :courses, :price, :decimal, :precision => 8, :scale => 2, :default => 0
     add_column :exams, :price, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def self.down
  end
end

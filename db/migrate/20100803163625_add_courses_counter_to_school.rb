class AddCoursesCounterToSchool < ActiveRecord::Migration
  def self.up
    add_column :schools, :courses_count, :integer, :default => 0
  end

  def self.down
    remove_column :scholls, :courses_count
  end
end

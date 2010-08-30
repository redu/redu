class AddSimpleCategoryToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :simple_category_id, :integer
    add_column :exams, :simple_category_id, :integer
    
    Course.update_all( "simple_category_id = 16") # seta todos os cursos com categoria (outro)
    Exam.update_all( "simple_category_id = 16") # seta todos os cursos com categoria (outro)
  end

  def self.down
  end
end

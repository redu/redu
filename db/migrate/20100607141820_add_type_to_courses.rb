class AddTypeToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :course_type, :string
    Courses.update_all("course_type = 'seminar'") # atualiza todos os cursos já cadastrados como seminar,
                                           # já que era o único tipo que tinhamos
  end

  def self.down
  end
end

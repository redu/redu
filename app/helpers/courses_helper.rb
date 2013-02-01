module CoursesHelper
  # Define o papel do usuário no Curso
  def user_course_role(course, user)
    uca = course.user_course_associations.select{
      |assoc| assoc.user_id == user.id }.first

    role = uca ? uca.role : nil
    role
  end
end

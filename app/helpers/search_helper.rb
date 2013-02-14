module SearchHelper
  # Define o papel do usuário no Ambiente
  def user_environment_role(environment, user)
    uea = environment.user_environment_associations.select{ |assoc|
      assoc.user_id == user.id }.first

    uea.try(:role)
  end

  # Define o papel do usuário no Curso
  def user_course_role(course, user)
    uca = course.user_course_associations.select{
      |assoc| assoc.user_id == user.id }.first

    uca.try(:role)
  end

  # Define se o link "Veja todos os resultados" deve ser mostrado.
  def show_see_all_results_link?(total_found)
    total_found > Redu::Application.config.search_preview_results_per_page
  end
end
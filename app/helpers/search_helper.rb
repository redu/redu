module SearchHelper
  # Define o papel do usuário no Ambiente
  def user_environment_role(environment, user)
    uea = environment.user_environment_associations.select{ |assoc|
      assoc.user_id == user.id }.first

    role_icon(uea.try(:role))
  end

  # Define o papel do usuário no Curso
  def user_course_role(course, user)
    uca = course.user_course_associations.select{
      |assoc| assoc.user_id == user.id }.first

    role_icon(uca.try(:role))
  end

  def role_icon(role)
    if [0, 3, 4].include? role
      "manager"
    elsif role == 6
      "tutor"
    elsif role == 5
      "teacher"
    else
      "member"
    end
  end

  # Define se o link "Veja todos os resultados" deve ser mostrado.
  def show_see_all_results_link?(total_found)
    total_found > Redu::Application.config.search_preview_results_per_page
  end

  # Define a formatação da lista de administradores
  def show_administrators_list(collection)
    collection.collect { |admin| admin.display_name }.join(', ')
  end
end

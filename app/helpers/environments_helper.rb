module EnvironmentsHelper
  # Define os cursos que o usuário tem acesso dentro de um ambiente
  def user_environment_courses(environment, user)
    environment.courses & user.courses
  end

  # Define o papel do usuário no Ambiente
  def user_environment_role(environment, user)
    uea = environment.user_environment_associations.select{ |assoc|
      assoc.user_id == user.id }.first

    role = uea ? uea.role : nil
    role
  end
end

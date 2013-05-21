# -*- encoding : utf-8 -*-
module EnvironmentsHelper
  # Define os cursos que o usuário tem acesso dentro de um ambiente
  def user_environment_courses(environment, user)
    environment.courses & user.courses
  end
end

# -*- encoding : utf-8 -*-
module EnvironmentsHelper
  # Define os cursos que o usuário tem acesso dentro de um ambiente
  def user_environment_courses(environment, user)
    environment.courses & user.courses
  end

  # Retorna se uma entidade está "ativa".
  def bootstrap_entity_is_active?(current_entity, type)
    # type varia entre todos os tipos de entidade.
    current_entity.class.to_s.downcase == type.to_s
  end
end

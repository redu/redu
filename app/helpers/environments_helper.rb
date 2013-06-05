# -*- encoding : utf-8 -*-
module EnvironmentsHelper
  # Define os cursos que o usuário tem acesso dentro de um ambiente
  def user_environment_courses(environment, user)
    environment.courses & user.courses
  end

  # Retorna se uma entidade está "ativa".
  def entity_is_active?(entity, key)
    # key varia entre todos os tipos de entidade.
    entity.class.to_s.downcase == key.to_s
  end
end

# Este módulo contém todos os métodos necessários para expirar
# caches de fragmentos.
#
# Os métodos para expirar os caches podem receber tanto único objeto,
# uma lista de objetos ou simplesmente vários objetos (sem a necessidade
# de estarem em uma lista)
#
# Para expirar a cache do fragmento do sidebar da home (lista de Environments):
# expire_sidebar_environments_for(user1)
# expire_sidebar_environments_for(user1, user2)
# expire_sidebar_environments_for([user1, user2])
module ViewCaches
  def expire_sidebar_environments_for(users)
    expire_fragments('home_sidebar_environments', users)
  end

  def expire_sidebar_connections_for(users)
    expire_fragments('home_sidebar_connections', users)
  end

  def expire_friends_requisitions_for(users)
    expire_fragments('home_friends_requisitions', users)
  end

  def expire_courses_requisitions_for(users)
    expire_fragments('home_courses_requisitions', users)
  end

  def expire_nav_account_for(users)
    expire_fragments('nav_account', users)
  end

  def expire_course_members_count_for(course)
    expire_fragments('course_members_count', course)
  end

  protected
  # Método genérico para expirar caches de fragmento para um ou
  # mais de um elemento.
  #
  # expire_fragments('my_fragment_name', user1)
  # expire_fragments('my_fragment_name', user1, user2)
  # expire_fragments('my_fragment_name', [user1, user2])
  def expire_fragments(name, *entities)
    entities.flatten.each do |entity|
      ActionController::Base.new.expire_fragment([name, entity.id])
    end
  end
end

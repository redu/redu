# Este módulo contém todos os métodos necessários para expirar
# caches de fragmentos.
#
# Os métodos para expirar os caches podem receber tanto único objeto,
# uma lista de objetos ou simplesmente vários objetos (sem a necessidade
# de estarem em uma lista)
#
# Para expirar a cache do fragmento do sidebar da home (lista de Environments):
# expire_friends_requisitions_for(user1)
# expire_friends_requisitions_for(user1, user2)
# expire_friends_requisitions_for([user1, user2])
module ViewCaches
  def expire_friends_requisitions_for(users)
    expire_fragments('home_friends_requisitions', users)
  end

  def expire_courses_requisitions_for(users)
    expire_fragments('home_courses_requisitions', users)
  end

  def expire_nav_global_dropdown_menu_for(users)
    expire_fragments('nav_global_dropdown_menu', users)
  end

  def expire_course_members_count_for(course)
    expire_fragments('course_members_count', course)
  end

  def expire_environment_sidebar_connections_with_count_for(environment)
    expire_fragments('environment_sidebar_connections_with_count', environment)
  end

  def expire_user_courses_count_for(users)
    expire_fragments('user_courses_count', users)
  end

  def expire_space_lectures_item_for(lecture, users)
    expire_nested_fragments('space_lecture_item', lecture, users)
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

  def expire_nested_fragments(name, entity, *entities)
    entities.flatten.each do |ent|
      ActionController::Base.new.expire_fragment([name, entity.id, ent.id])
    end
  end
end

# -*- encoding : utf-8 -*-
module StatusesHelper
  def role_at(user, entity)
    association = user.get_association_with(entity)
    return "" if association.nil?

    Role[association.try(:role)]
  end

  def status_message(msg)
    # Processa aspas envolvendo links e quebras de linha
    raw auto_link(h(msg).gsub(/\n/, '</br>').gsub(/&quot\;/, '"'))
  end

  # Retorna o nome da partial correta de um dado tipo de log.
  def log_partial(logeable_type)
    case logeable_type
    when "User" then "user"
    when "Education" then "user"
    when "Experience" then "user"
    when "Friendship" then "friendship"
    when "Course" then "course"
    when "Space" then "space"
    when "Subject" then "subject"
    when "Lecture" then "lecture"
    when "CourseEnrollment" then "user_course_association"
    end
  end

  # Retorna o nome da partial correta de um dado tipo de compound log.
  def compound_log_partial(logeable_type)
    case logeable_type
    when "Friendship" then "friendship_compound"
    when "UserCourseAssociation" then "uca_compound"
    end
  end

  # Retorna o nome da partial correta de um dado tipo de status
  # que pode ser respondido.
  def answerable_status_partial(item)
    case item.statusable_type
    when "Lecture"
      if item.type == "Help"
        "lecture_help"
      else
        "lecture"
      end
    when "Space" then "space"
    else "friend"
    end
  end

  # Retorna o texto correto da ação de comentar no
  # seu próprio mural ou no mural de um amigo.
  def comment_self_or_friend_wall_action(item)
    text = "comentou no "
    if item.statusable.eql?(item.user)
      text << "seu próprio "
      text << link_to("Mural", show_mural_user_path(item.user))
    else
      text << link_to("Mural", show_mural_user_path(item.statusable))
      text << " de "
      text << link_to(item.statusable.display_name, user_path(item.statusable))
    end
    text << ":"

    raw text
  end

  def can_render_status?(status)
    is_a_log = true if status.logeable_type

    status.statusable && (is_a_log ? status.logeable : true)
  end
end

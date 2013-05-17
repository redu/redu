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
end

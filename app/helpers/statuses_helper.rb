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
  def log_partial_name(item)
    logeable_type = item.logeable_type
    if logeable_type == "Experience" || logeable_type == "Education"
      "user"
    else
      logeable_type.underscore
    end
  end

  # Retorna o nome da partial correta de um dado tipo de status
  # que pode ser respondido.
  def comment_partial_name(item)
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

  # Retorna o caminho da hierarquia até o elemento dado com links.
  def context_path(item)
    lecture = ''
    subject = ''
    space = ''
    course = ''
    environment = ''

    if defined? item.subject
      lecture = item
      subject = lecture.subject
      space = subject.space
      course = space.course
    end

    if defined? item.space
      subject = item
      space = subject.space
      course = space.course
    end

    if defined? item.course
      space = item
      course = space.course
    end

    if defined? item.environment
      course = item
    end

    environment = course.environment
    environment_link = link_to(environment.name, environment_path(environment))

    unless lecture.blank?
      lecture_link = link_to(lecture.name, space_subject_lecture_path(space, subject, lecture))
    end

    unless space.blank?
      space_link = link_to(space.name, space_path(space))
    end

    unless course.blank?
      course_link = link_to(course.name, environment_course_path(environment, course))
    end

    [environment_link, course_link, space_link, lecture_link].compact.join(' > ')
  end
end

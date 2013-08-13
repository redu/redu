# -*- encoding : utf-8 -*-
module CoursesHelper
  # Retorna a legenda adequada para o tipo de privacidade de um curso.
  def course_privacy_legend(course)
    # Todos.
    if course.subscription_type == 1
      if can?(:read, course)
        "Entrada livre — Você já faz parte deste Curso"
      else
        "Entrada livre"
      end
    # Entrada moderada.
    else
      if can?(:show, course)
        "Entrada moderada — Você já faz parte deste Curso."
      else
        "Entrada moderada — Este Curso requer aprovação de matrícula."
      end
    end
  end

  # Dado um curso privado, retorna um hash com a cor do ícone e seu texto.
  def private_course_info(course)
    unless course.subscription_type == 1
      if can?(:manage, course)
        if course.user_course_associations.waiting.exists?
          { color: "green",
            text: "Curso fechado, existem alunos na fila de moderação."}
        else
          { color: "gray",
            text: "Curso fechado, não existem alunos na fila de moderação."}
        end
      elsif can?(:show, course)
        { color: "gray", text: "Curso fechado e você tem acesso."}
      else
        { color: "red2", text: "Curso fechado"}
      end
    end
  end

  # Retorna a privacidade de um curso com suas devidas classes.
  def course_privacy_type(course)
    if course[:type] == :public
      content_tag(:span, "Aberto",
                  class: "course-privacy-open icon-privacy-open-green_16_18-before")
    else
      content_tag(:span, "Privado",
                  class: "course-privacy-closed icon-privacy-closed-red_16_18-before")
    end
  end
end

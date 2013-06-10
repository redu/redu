# -*- encoding : utf-8 -*-
module SubjectsHelper
  def item_expander(item, subject)
    if item.eql?(subject)
      display_css = "block"
      expand_css = "up"
    else
      display_css = "none"
      expand_css = "down"
    end
    [display_css, expand_css]
  end

  # Retorna o ícone da visibilidade do módulo.
  def icon_visiblity_class(subject)
    if subject.visible?
      "visible"
    else
      "invisible"
    end
  end

  # Retorna o texto usado no tooltip do ícone de visibilidade do módulo.
  def icon_visibility_text(subject)
    visibility = if subject.visible?
      "visível"
    else
      "invisível"
    end

    "Módulo #{visibility} para os alunos"
  end
end

# -*- encoding : utf-8 -*-
module ResultsHelper
  def completude_message(choices_count, questions_count)
    content_tag(:span, class: "exercise-call") do
      if choices_count == questions_count
        "Parabéns você respondeu #{content_tag(:strong, "todas", class: "exercise-full")} as questões do exercício!".html_safe
      else
        "Você só respondeu #{choices_count} de #{pluralize questions_count, "questão", "questões"}"
      end
    end
  end
end

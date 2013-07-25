# -*- encoding : utf-8 -*-
module ResultsHelper
  # Retorna mensagem da completudo do exercício.
  def completeness_message(choices_count, questions_count)
    if choices_count == questions_count
      "Parabéns você respondeu #{ content_tag(:strong, "todas", class: "exercise-summary-value-finalized") } as questões do exercício!".html_safe
    else
      "Você só respondeu #{ choices_count } de #{ pluralize questions_count, 'questão', 'questões' }"
    end
  end

  # Retorna o botão de submissão do exercício.
  def exercise_submit_button(choices_count, questions_count)
    options = { class: "exercise-form-submission-submit button-primary button-big icon-exercise-white_blue_16_18-before" }
    if choices_count != questions_count
      options[:data] = { confirm: "Você só respondeu #{ choices_count } de #{ pluralize questions_count, 'questão', 'questões' }, tem certeza que deseja submeter?"}
    end

    button_tag "Submeter", options
  end
end
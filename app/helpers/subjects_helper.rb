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

  def retract_question(question)
    if question.errors.empty? && (action_name != 'new')
      question_visibility = "closed"
      summary_visibility = "block"
      fields_visibility = "none"
    else
      question_visibility = ""
      summary_visibility = "none"
      fields_visibility = "block"
    end
    [question_visibility, summary_visibility, fields_visibility]
  end

  def correct_alternative_order_for(question)
    # Questão apenas no form
    i = if question.new_record?
      question.alternatives.collect { |a| a.correct }.index(true)
    else
      # Questão já existente
      correct = question.correct_alternative
      question.alternatives.index(correct) if correct
    end

    if i
      ('A'..'Z').to_a[i]
    else
      # Questão sem alternativa correta assinalada
      "(não marcada)"
    end
  end
end

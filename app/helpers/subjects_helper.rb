module SubjectsHelper
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
end

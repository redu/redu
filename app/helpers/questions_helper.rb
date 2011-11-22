module QuestionsHelper
  def pagination(current)
    inf = 1.0/0
    case current.position
    when 1..4
      offset = 0
      limit = current.position + 3
    when 5..inf
      limit = 7
      offset = current.position - 4
    end

    [limit, offset]
  end

  def questions_array(size, questions, current)
    position = current.position

    left_questions = 0
    left_questions = 4 - position if 4 - position > 0

    left_questions.times do
      questions = [nil] + questions
    end

    questions
  end
end

# -*- encoding : utf-8 -*-
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
end

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
end

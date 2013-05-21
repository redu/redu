# -*- encoding : utf-8 -*-
class EducationObserver < ActiveRecord::Observer
  def after_create(education)
    Log.setup(education, :action => :create, :text => "adicinou uma nova formação")
  end
end

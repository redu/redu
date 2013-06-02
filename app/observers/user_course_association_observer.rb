# -*- encoding : utf-8 -*-
class UserCourseAssociationObserver < ActiveRecord::Observer
  def after_update(uca)
    Log.setup(uca, :action => :create, :text => 'ingressou no Curso')
    uca.course.touch
  end
end

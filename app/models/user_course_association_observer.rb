class UserCourseAssociationObserver < ActiveRecord::Observer
  def after_update(uca)
    uca.course.touch
  end
end

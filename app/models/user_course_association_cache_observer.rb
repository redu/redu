class UserCourseAssociationCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe UserCourseAssociation

  def after_create(uca)
    expire_courses_requisitions_for(uca.user)
  end

  def after_update(uca)
    if uca.state_changed? && uca.approved?
      expire_all_course_requisitions(uca)
    end
  end

  def after_destroy(uca)
    if uca.rejected?
      expire_courses_requisitions_for(uca.user)
    else
      expire_all_course_requisitions(uca)
    end
  end

  protected
  def expire_all_course_requisitions(uca)
    #FIXME Refactor please
    invited_users = uca.course.user_course_associations.invited.
      includes(:user).collect(&:user)

    expire_courses_requisitions_for(invited_users)
  end

end

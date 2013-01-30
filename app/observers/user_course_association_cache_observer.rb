class UserCourseAssociationCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe UserCourseAssociation

  def after_create(uca)
    expire_courses_requisitions_for(uca.user)
    expire_user_courses_count_for(uca.user)
  end

  def after_update(uca)
    if uca.state_changed? && (uca.approved? || uca.rejected?)
      expire_all_course_requisitions(uca)
      expire_courses_requisitions_for(uca.user)
      expire_course_members_count_for(uca.course)
    elsif uca.role_changed?
      expire_course_members_count_for(uca.course)
    end
  end

  def after_destroy(uca)
    if uca.approved?
      expire_all_course_requisitions(uca)
    end
    expire_course_members_count_for(uca.course)
    expire_user_courses_count_for(uca.user)
  end

  protected
  def expire_all_course_requisitions(uca)
    #FIXME Refactor please
    invited_users = uca.course.user_course_associations.invited.
      includes(:user).collect(&:user)

    expire_courses_requisitions_for(invited_users)
  end

end

class CourseCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe Course

  def after_update(course)
    #FIXME Refactor please
    invited_users = course.user_course_associations.invited.
      includes(:user).collect(&:user)

    expire_courses_requisitions_for(invited_users)
  end
end

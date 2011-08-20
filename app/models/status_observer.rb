class StatusObserver < ActiveRecord::Observer
  def after_create(status)
    case status.statusable.class.to_s
    when "User"
      status.user.status_user_associations.create(:status => status)
      status.associate_with(status.user.friends)
      status.associate_with(status.statusable.friends)
    when "Lecture"
      course = status.statusable.subject.space.course
      associate_with_approved_users(course, status)
    when "Space"
      associate_with_approved_users(status.statusable.course, status)
    when "Course"
      associate_with_approved_users(status.statusable, status)
    end
  end

  protected

  def associate_with_approved_users(course, status)
    status.associate_with(course.approved_users)
  end
end

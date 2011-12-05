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

    # creating notifiables
    status.status_user_associations.each do |assoc|
      n = Notifiable.find_or_initialize_by_user_id_and_name(assoc.user.id, "Speaker")
      n.increment_counter
      n.save
    end
  end

  protected

  def associate_with_approved_users(course, status)
    status.associate_with(course.approved_users)
  end
end

class HierarchyStatusesJob
  attr_accessor :status_id, :course_id

  def initialize(status_id, course_id)
    @status_id = status_id
    @course_id = course_id
  end

  def perform
    course = Course.find(course_id)
    status = Status.find(status_id)

    if course && status
      Status.associate_with(status, course.approved_users.select("users.id"))
    end
  end
end

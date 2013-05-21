# -*- encoding : utf-8 -*-
class HierarchyStatusesJob
  attr_accessor :status_id, :course_id

  def initialize(opts)
    @status_id = opts[:status_id]
    @course_id = opts[:course_id]
  end

  def perform
    course = Course.find_by_id(course_id)
    status = Status.find_by_id(status_id)

    if course && status
      Status.associate_with(status, course.approved_users.select("users.id"))
    end
  end
end

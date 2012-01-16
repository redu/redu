class CourseObserver < ActiveRecord::Observer
  def after_create(course)
    Log.setup(course, :action => :create)
  end

  def before_destroy(course)
    if plan = course.plan
      plan.audit_billable!
    end
  end
end

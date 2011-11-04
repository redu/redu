class LectureObserver < ActiveRecord::Observer
  def after_create(lecture)
    Log.setup(lecture, :action => :create)
    space = lecture.subject.space
    space.update_attribute(:lectures_count, space.lectures_count + 1)
  end

  def after_destroy(lecture)
    space = lecture.subject.space
    space.update_attribute(:lectures_count, space.lectures_count - 1)
  end
end

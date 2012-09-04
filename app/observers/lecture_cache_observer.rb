class LectureCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe Lecture

  def before_update(lecture)
    if lecture.name_changed? or lecture.rating_average_changed?
      expire_space_lectures_item_for(lecture, lecture.subject.members)
    end
  end

  def after_destroy(lecture)
    expire_space_lectures_item_for(lecture, lecture.subject.members)
  end
end

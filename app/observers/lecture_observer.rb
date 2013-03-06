class LectureObserver < ActiveRecord::Observer
  def after_create(lecture)
    Log.setup(lecture, :action => :create)

    if lecture.lectureable.external?
      lecture.lectureable.update_attributes(:state => "converted")
    end
  end
end

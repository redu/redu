class LectureObserver < ActiveRecord::Observer
  def after_create(lecture)
    Log.setup(lecture, :action => :create)
  end
end

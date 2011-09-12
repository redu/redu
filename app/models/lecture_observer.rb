class LectureObserver < ActiveRecord::Observer
  def after_create(lecture)
    Log.setup(lecture, :text => "publicou a aula")
  end
end

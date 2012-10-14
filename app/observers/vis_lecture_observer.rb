class VisLectureObserver < ActiveRecord::Observer

  observe :lecture

  def before_destroy(lecture)
    if exercise? lecture
      job = ExerciseFinalizedNotificationJob.new(lecture)
      Delayed::Job.enqueue(job, :queue => 'general')
    end
  end

  protected

  def exercise?(lecture)
    lecture.lectureable_type == "Exercise"
  end
end

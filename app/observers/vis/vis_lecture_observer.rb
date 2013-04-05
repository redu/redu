class VisLectureObserver < ActiveRecord::Observer
  observe :lecture

  def before_destroy(lecture)
    lectureable = lecture.lectureable
    if lectureable.is_a? Exercise
      finalized_results = lectureable.results.select do |r|
        r.finalized?
      end

      VisClient.notify_delayed("/hierarchy_notifications.json",
                               "remove_exercise_finalized",
                               finalized_results)
    end
  end
end

class ExerciseFinalizedNotificationJob
  include ExerciseVisNotification

  attr_accessor :lecture

  def initialize(lecture)
    @lecture = lecture
  end

  def perform
    lecture.lectureable.results.each do |result|
      if finalized? result
        send_to_vis(result, true)
      end
    end
  end

  protected

  def finalized?(result)
    result.finalized_at && result.duration &&
      result.grade && result.state == "finalized"
  end
end

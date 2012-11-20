class ResultObserver < ActiveRecord::Observer
  include ExerciseVisNotification

  def before_update(result)
    if finalized? result
      send_to_vis(result, false)
    end
  end

  protected

  def finalized?(result)
    result.finalized_at && result.duration &&
      result.grade && result.state == "finalized"
  end
end

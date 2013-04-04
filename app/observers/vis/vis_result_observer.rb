class VisResultObserver < ActiveRecord::Observer
  observe :result

  def before_update(result)
    if result.finalized? && result.state_changed?
      VisClient.notify_delayed("/hierarchy_notifications.json",
                               "exercise_finalized", result)
    end
  end
end

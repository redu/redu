class VisStatusObserver < ActiveRecord::Observer
  observe :status

  def after_create(status)
    unless status.is_a? CompoundLog
      case status.statusable.class.to_s
      when "Lecture", "Space"
        VisClient.notify_delayed("/hierarchy_notifications.json",
                                 status.type.downcase, status.becomes(Status))
      when "Activity", "Help"
        unless status.statusable.statusable.is_a? User
          VisClient.notify_delayed("/hierarchy_notifications.json",
                                   ("answered_"+status.statusable.type.downcase),
                                   status.becomes(Status))
        end
      end
    end
  end

  def after_destroy(status)
    unless status.is_a? CompoundLog
      case status.statusable.class.to_s
      when "Lecture", "Space"
        VisClient.notify_delayed("/hierarchy_notifications.json",
                                 ("remove_"+status.type.downcase),
                                 status.becomes(Status))
      when "Activity", "Help"
        unless status.statusable.statusable.is_a? User
          VisClient.notify_delayed("/hierarchy_notifications.json",
                                   ("remove_answered_"+status.statusable.type.downcase),
                                   status.becomes(Status))
        end
      end
    end
  end
end

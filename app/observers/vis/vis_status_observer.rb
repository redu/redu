# -*- encoding : utf-8 -*-
class VisStatusObserver < ActiveRecord::Observer
  observe :status

  def after_create(status)
    unless is_a_log? status
      case status.statusable.class.to_s
      when "Lecture", "Space"
        VisClient.notify_delayed("/hierarchy_notifications.json",
                                 status.type.downcase, status)
      when "Activity", "Help"
        unless status.statusable.statusable.is_a? User
          VisClient.notify_delayed("/hierarchy_notifications.json",
                                   ("answered_"+status.statusable.type.downcase),
                                   status)
        end
      end
    end
  end

  def after_destroy(status)
    unless is_a_log? status
      case status.statusable.class.to_s
      when "Lecture", "Space"
        VisClient.notify_delayed("/hierarchy_notifications.json",
                                 ("remove_"+status.type.downcase),
                                 status)
      when "Activity", "Help"
        unless status.statusable.statusable.is_a? User
          VisClient.notify_delayed("/hierarchy_notifications.json",
                                   ("remove_answered_"+status.statusable.type.downcase),
                                   status)
        end
      end
    end
  end

  private

  def is_a_log?(status)
    (status.is_a? CompoundLog)  || (status.is_a? Log)
  end
end

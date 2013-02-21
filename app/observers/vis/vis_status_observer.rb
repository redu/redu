class VisStatusObserver < ActiveRecord::Observer
  include StatusVisNotification

  observe :status

  #def after_create(status)
  #  unless status.is_a? CompoundLog
  #    case status.statusable.class.to_s
  #    when "Lecture"
  #      send_to_vis(status, false)
  #    when "Space"
  #      send_to_vis(status, false)
  #    when "Activity", "Help"
  #      unless status.statusable.statusable.is_a? User
  #        send_to_vis(status, false)
  #      end
  #    end
  #  end
  #end

  #def after_destroy(status)
  #  unless status.is_a? CompoundLog
  #    case status.statusable.class.to_s
  #    when "Lecture"
  #      send_to_vis(status, true)
  #    when "Space"
  #      send_to_vis(status, true)
  #    when "Activity", "Help"
  #      unless status.statusable.statusable.is_a? User
  #        send_to_vis(status, true)
  #      end
  #    end
  #  end
  #end
end

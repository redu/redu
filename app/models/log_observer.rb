class LogObserver < ActiveRecord::Observer

  def after_create(log)
    # Compõe apenas logs com logeable Friendship e UserCourseAssociation
    case log.logeable
    when Friendship, UserCourseAssociation
      log.process_compound
    end
  end
end

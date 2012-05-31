class LogObserver < ActiveRecord::Observer

  def after_create(log)
    # Compõe apenas logs com logeable Friendship e UserCourseAssociation
    case log.logeable
    when Friendship, UserCourseAssociation
      compound_log = CompoundLog.current_compostable(log)
      compound_log.compound!(log)
    end
  end
end

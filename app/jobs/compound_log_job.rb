class CompoundLogJob
  attr_accessor :log_id

  def initialize(compound_log_id)
    @compound_log_id = compound_log_id
  end

  def perform
    compound_log = CompoundLog.find(@compound_log_id)

    if compound_log
      case compound_log.logeable_type
      when 'UserCourseAssociation'
        Status.associate_with(compound_log, compound_log.statusable.approved_users.select('users.id'))
      when 'Friendship'
        Status.associate_with(compound_log, compound_log.statusable.friends.select('users.id'))
      end
    end
  end
end

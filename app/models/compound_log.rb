class CompoundLog < Status
  has_many :logs, :dependent => :destroy

  scope :by_logeable_type, lambda { |type| where(:logeable_type => type)}

  def compound!(log)
    self.logs << log
    self.compound_visible_at = Time.now
    self.compound = false
    self.save!
  end

  # Return last compound able to group logs.
  # If the interval time of compound has expired,
  # a new compound log is created
  def self.current_compostable(status, interval=24)
    statusable = status.statusable

    compound_logs = CompoundLog.by_statusable(statusable.class.to_s,
                                              statusable.id).by_logeable_type(status.logeable_type)

    compound_log = compound_logs.sort{ |i,j| i.created_at <=> j.created_at }.last

    # Exists compound and has visible
    if compound_log and compound_log.compound_visible_at
      compound_log = nil if compound_log.compound_visible_at <= Time.now.ago(interval.hours)
    end

    compound_log ||= CompoundLog.create(:statusable => status.statusable,
                                        :compound => true,
                                        :logeable_type => status.logeable.class.to_s,
                                        :user => status.user)
  end
end

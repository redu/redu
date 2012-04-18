class CompoundLog < Status
  has_many :logs, :dependent => :destroy

  def compound!(log)
	self.logs << log
	self.compound = false
	self.compound_visible_at = Time.now
  end

  scope :by_logeable_type, lambda { |type| where(:logeable_type => type)}

  def self.last_compostable(status, interval=24)
    statusable = status.statusable
    logeable_type = status.logeable_type

    compound_logs = CompoundLog.by_statusable(statusable.class.to_s, statusable.id).by_logeable_type(logeable_type)

    compound_log = compound_logs.sort{ |i,j| i.created_at <=> j.created_at }.last

    if compound_log
      p compound_log
      compound_log = nil if compound_log.compound_visible_at > interval.hours.ago
    end

    compound_log ||= CompoundLog.create(:statusable => status.statusable,
                                          :compound => true,
                                          :logeable_type => status.logeable.class.to_s,
                                          :user => status.user)
  end
end

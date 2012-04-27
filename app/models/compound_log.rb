class CompoundLog < Status
  has_many :logs, :dependent => :destroy

  scope :by_logeable_type, lambda { |type| where(:logeable_type => type)}

  def compound!(log, min_logs=4)
    self.logs << log
    if self.logs.count == min_logs
      self.compound_visible_at = Time.now
      self.compound = false
      self.save!
    end
  end

  def expired?(interval)
    if self.compound_visible_at
      self.compound_visible_at <= Time.now.ago(interval.hours)
    end
  end

  # Return last compound able to group logs.
  # If the interval time of compound has expired,
  # a new compound log is created
  def self.current_compostable(log, interval=24)
    compound_logs = CompoundLog.where(:user_id => log.user,
                                      :logeable_type => log.logeable.class.to_s)

    compound_log = compound_logs.order("created_at ASC").limit(1).last

    compound_log = nil if (compound_log and compound_log.expired?(interval))
    compound_log ||= CompoundLog.create(:statusable => log.statusable,
                                        :compound => true,
                                        :logeable_type => log.logeable.class.to_s,
                                        :user => log.user)
  end
end

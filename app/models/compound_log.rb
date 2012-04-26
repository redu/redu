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

    compound_log = case log.logeable.class.to_s
                   when "Friendship"
                     find_friendship_compound(log, interval)
                   when "UserCourseAssociation"
                     find_uca_compound(log, interval)
                   else
                     nil
                   end
  end

  def self.find_friendship_compound(log, interval)
    compound_logs = CompoundLog.where(:user_id => log.user,
                                      :logeable_type => log.logeable.class.to_s)

    compound_log = compound_logs.order("created_at ASC").limit(1).last

    compound_log = nil if (compound_log and compound_log.expired?(interval))
    compound_log ||= CompoundLog.create(:statusable => log.user,
                                        :compound => true,
                                        :logeable_type => log.logeable.class.to_s,
                                        :user => log.user)
  end

  def self.find_uca_compound(log, interval)
  # FIXME: modificar busca e criação do compound para uca
  # o compound deve agrupar todos os usuários matrículados no curso
    compound_logs = CompoundLog.where(:user_id => log.user,
                                      :logeable_type => log.logeable.class.to_s)

    compound_log = compound_logs.order("created_at ASC").limit(1).last

    compound_log = nil if (compound_log and compound_log.expired?(interval))
    compound_log ||= CompoundLog.create(:statusable => log.user,
                                        :compound => true,
                                        :logeable_type => log.logeable.class.to_s,
                                        :user => log.user)
  end
  private_class_method :find_uca_compound
  private_class_method :find_friendship_compound
end

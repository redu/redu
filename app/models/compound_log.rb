class CompoundLog < Status
  has_many :logs

  before_destroy :update_compounded_logs_compound_property

  def compound!(log, min_logs=3)
    self.logs << log
    log.update_attributes(:compound => true) if self.compound_visible_at

    if self.logs.count == min_logs
      self.update_attributes(:compound_visible_at => Time.now, :compound => false)
      self.update_compounded_logs_compound_property(true)
      self.save!
    end
  end

  def expired?(interval)
    self.compound_visible_at <= interval.hours.ago if self.compound_visible_at
  end

  protected

  # Retorna o último compound_log (em que devem ser agrupados novos logs).
  def self.current_compostable(log, interval=24)
    compound_logs = CompoundLog.where(:statusable_id => log.statusable,
                                      :logeable_type => log.logeable.class.to_s)

    compound_log = compound_logs.order("created_at ASC").limit(1).last

    # Cria novo compound_log se o último estiver expirado.
    compound_log = nil if (compound_log and compound_log.expired?(interval))
    compound_log ||= self.create_and_setup(log)
  end

  # Cria um novo compound_log
  def self.create_and_setup(log)
    CompoundLog.create(:statusable => log.statusable,
                       :compound => true,
                       :logeable_type => log.logeable.class.to_s,
                       :user => log.user)
  end

  # False significa que logs não estão compostos, logo devem ser exibidos
  def update_compounded_logs_compound_property(compound = false)
    self.logs.each do |log|
      log.update_attributes(:compound => compound)
    end
  end
end

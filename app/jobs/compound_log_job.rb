class CompoundLogJob
  attr_accessor :log_id

  # Asssocia os agrupamentos aos stakeholders
  def initialize(compound_log_id)
    @compound_log_id = compound_log_id
  end

  def perform
    compound_log = CompoundLog.find(@compound_log_id)
    compound_log.statusable.notify(compound_log) if compound_log
  end
end

class CompoundLogJob
  attr_accessor :log_id

  def initialize(log_id)
    @log_id = log_id
  end

  def perform
    log = Log.find(@log_id)

    if log
      compound_log = CompoundLog.current_compostable(log)
      compound_log.compound!(log) if compound_log
    end
  end
end

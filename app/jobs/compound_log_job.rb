# -*- encoding : utf-8 -*-
class CompoundLogJob
  attr_accessor :compound_log_id

  # Asssocia os agrupamentos aos stakeholders
  def initialize(opts)
    @compound_log_id = opts[:compound_log_id]
  end

  def perform
    compound_log = CompoundLog.find(compound_log_id)
    compound_log.statusable.notify(compound_log) if compound_log
  end
end

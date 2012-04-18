class CompoundLog < Status
  has_many :logs, :dependent => :destroy

  # 
  def compound!(log)
	self.logs << log
	self.compound = false
	self.visible_at = Time.now
  	# if compound_log
    #   # Já existe log composto: verifica se deve habilitá-lo
    #   if compound_log.logs.count == 4
    #     compound_log.logs << self
    #     compound_log.compound = false # Exibe status na view
    #     new_compound = CompoundLog.new(:statusable_type => self.statusable_type,
    #                                    :statusable_id => self.statusable_id,
    #                                    :compound => true) # Não exibe status na view  
    #   end
    # else
    #   # Não existe log composto: cria e associa novo log
    #   compound_log = CompoundLog.new(:statusable_type => self.statusable_type,
    #                                  :statusable_id => self.statusable_id,
    #                                  :compound => true) # Não exibe status na view
    #   compound_log.logs << self
    #   self.compound = false # Exibe status na view
    # end
  end
end

class CompoundLog < Status
  has_many :logs, :dependent => :destroy

  def should_compound?

  end

  def self.compound(logs)

  end
end

class HigherEducation < ActiveRecord::Base
  # Representa uma formação do usuário no Ensino Superior
  # É uma especialização de Education

  has_one :education, :as => :educationable

  validates_presence_of :kind, :institution, :start_year, :end_year
  validates_presence_of :course, :if => Proc.new { |h| h.technical? or
    h.degree? or h.bachelorship? }
  validates_presence_of :research_area,
    :if => Proc.new {|h| h.pos_stricto_sensu? or h.pos_lato_sensu? or
      h.doctorate? or h.phd? }
  validates_inclusion_of :kind, :in => %w(technical degree bachelorship
    pos_stricto_sensu pos_lato_sensu doctorate phd)

  def technical?
    self.kind == "technical"
  end

  def degree?
    self.kind == "degree"
  end

  def bachelorship?
    self.kind == "bachelorship"
  end

  def pos_stricto_sensu?
    self.kind == "pos_stricto_sensu"
  end

  def pos_lato_sensu?
    self.kind == "pos_lato_sensu"
  end

  def doctorate?
    self.kind == "doctorate"
  end

  def phd?
    self.kind == "phd"
  end
end

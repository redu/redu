class Country < ActiveRecord::Base

  # ASSOCIATIONS
  has_many :states

  def self.get(name)
    case name
    when :us
      c = 'United States'
    end
    self.find_by_name(c)
  end

  def self.find_countries_with_metros
    MetroArea.includes(:country).collect{ |m| m.country }.sort_by{ |c| c.name }.uniq
  end

  def states
  end
end

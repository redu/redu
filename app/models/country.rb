class Country < ActiveRecord::Base

  # ASSOCIATIONS
  has_many :metro_areas
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
    State.includes(:metro_areas).where("metro_areas.id in (?)", metro_area_ids).uniq
  end

  def metro_area_ids
    metro_areas.map{|m| m.id }
  end
end

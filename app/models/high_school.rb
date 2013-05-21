# -*- encoding : utf-8 -*-
class HighSchool < ActiveRecord::Base
  # Representa uma formação do usuário no Ensino Médio
  # É uma especialização de Education

  has_one :education, :as => :educationable

  validates_presence_of :institution, :end_year
end

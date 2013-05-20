# -*- encoding : utf-8 -*-
class ComplementaryCourse < ActiveRecord::Base
  # Representa uma formação do usuário em um Curso Complementar
  # É uma especialização de Education

  has_one :education, :as => :educationable

  validates_presence_of :course, :institution, :year, :workload
end

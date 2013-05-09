class EventEducation < ActiveRecord::Base
  # Representa um evento escolar/acadêmico que o usuário participou
  # É uma especialização de Education

  has_one :education, :as => :educationable

  validates_presence_of :name, :role, :year
  validates_inclusion_of :role, :in => %w(participant speaker organizer)
end

class EventEducation < ActiveRecord::Base
  validates_presence_of :name, :role, :year
  validates_inclusion_of :role, :in => %w(participant speaker organizer)
end

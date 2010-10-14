class Bulletin < ActiveRecord::Base
  #PLUGINS
  acts_as_taggable
  acts_as_voteable
  ajaxful_rateable :stars => 5

  #ASSOCIATIONS
  belongs_to :school
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"

  #VALIDATIONS
  validates_presence_of :title, :description, :tagline
  validates_presence_of :owner
  validates_presence_of :school
  validates_length_of :tagline, :maximum => AppConfig.desc_char_limit

  # Máquina de estados para moderação das Notícias
  acts_as_state_machine :initial => :waiting

  state :waiting
  state :approved
  state :rejected
  state :error

  event :approve do
    transitions :from => :waiting, :to => :approved
  end

  event :reject do
    transitions :from => :waiting, :to => :rejected
  end
end

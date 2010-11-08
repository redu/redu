class Bulletin < ActiveRecord::Base

  # ASSOCIATIONS
  belongs_to :space
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"

  # PLUGINS
  acts_as_taggable
  acts_as_voteable
  ajaxful_rateable :stars => 5
  # Máquina de estados para moderação das Notícias
  acts_as_state_machine :initial => :waiting
  state :waiting
  state :approved
  state :rejected
  state :error #FIXME estado sem transicões, é assim mesmo?

  event :approve do
    transitions :from => :waiting, :to => :approved
  end

  event :reject do
    transitions :from => :waiting, :to => :rejected
  end

  # VALIDATIONS
  validates_presence_of :title, :description, :tagline
  validates_presence_of :owner
  validates_presence_of :space
  validates_length_of :tagline, :maximum => AppConfig.desc_char_limit

end

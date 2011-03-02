class Bulletin < ActiveRecord::Base

  # ASSOCIATIONS
  has_many :logs, :as => :logeable, :dependent => :destroy, :class_name => 'Status'
  belongs_to :bulletinable, :polymorphic => true
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"

  # NAMED_SCOPE
  named_scope :waiting, :conditions => { :state => 'waiting' }
  named_scope :approved, :conditions => { :state => 'approved' }

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
  validates_presence_of :title, :description, :owner, :bulletinable
  validates_length_of :title, :maximum => 60
  validates_length_of :description, :maximum => 5000

end

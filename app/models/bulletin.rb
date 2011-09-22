class Bulletin < ActiveRecord::Base
  include AASM

  # ASSOCIATIONS
  belongs_to :bulletinable, :polymorphic => true
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"

  # SCOPES
  scope :waiting, where(:state => 'waiting')
  scope :approved, where(:state => 'approved')

  # PLUGINS
  acts_as_taggable
  ajaxful_rateable :stars => 5

  # Máquina de estados para moderação das Notícias
  aasm_column :state

  aasm_initial_state :waiting

  aasm_state :waiting
  aasm_state :approved
  aasm_state :rejected
  aasm_state :error #FIXME estado sem transicões, é assim mesmo?

  aasm_event :approve do
    transitions :to => :approved, :from => [:waiting]
  end

  aasm_event :reject do
    transitions :to => :rejected, :from => [:waiting]
  end

  # VALIDATIONS
  validates_presence_of :title, :description, :owner, :bulletinable
  validates_length_of :title, :maximum => 60
  validates_length_of :description, :maximum => 5000

end

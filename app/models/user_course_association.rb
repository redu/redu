class UserCourseAssociation < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_enumerated :role

  validates_uniqueness_of :user_id, :scope => :course_id

  # Máquina de estados para moderação das Notícias
  acts_as_state_machine :initial => :waiting
  state :waiting
  state :approved
  state :rejected
  state :failed

  event :approve do
    transitions :from => :waiting, :to => :approved
  end

  event :reject do
    transitions :from => :waiting, :to => :rejected
  end

  event :fail do
    transitions :from => :waiting, :to => :failed
  end
end

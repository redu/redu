class UserCourseAssociation < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_enumerated :role

  # Filtra por papéis (lista)
  named_scope :with_roles, lambda { |roles|
    unless roles.empty?
      { :conditions => { :role_id => roles.flatten } }
    end
  }
  # Filtra por palavra-chave (procura em User)
  named_scope :with_keyword, lambda { |keyword|
    if not keyword.empty? and keyword.size > 4
      { :conditions => [ "users.first_name LIKE :keyword " + \
        "OR users.last_name LIKE :keyword " + \
        "OR users.login LIKE :keyword", {:keyword => "%#{keyword}%"}],
        :include => [{ :user => {:user_space_associations => :space} }]}
    end
  }

  named_scope :recent, lambda {
      {:conditions => [ "created_at >= ?", 1.week.ago]}
  }

  # Máquina de estados para moderação das dos usuários nos courses.
  acts_as_state_machine :initial => :waiting
  state :waiting
  state :invited, :enter => :send_course_invitation_notification
  state :approved, :enter => :create_hierarchy_associations
  state :rejected
  state :failed

  event :invite do
    transitions :from => :waiting, :to => :invited
  end

  event :approve do
    transitions :from => :waiting, :to => :approved
  end

  event :accept do
    transitions :from => :invited, :to => :approved
  end

  event :reject do
    transitions :from => :waiting, :to => :rejected
  end

  event :deny do
    transitions :from => :invited, :to => :rejected
  end

  event :fail do
    transitions :from => :waiting, :to => :failed
  end

  validates_uniqueness_of :user_id, :scope => :course_id

  protected

  def send_course_invitation_notification
    UserNotifier.deliver_course_invitation_notification(self.user, self.course)
  end

  def create_hierarchy_associations
    self.course.create_hierarchy_associations(self.user)
  end
end

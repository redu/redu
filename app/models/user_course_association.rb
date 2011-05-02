class UserCourseAssociation < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_enumerated :role

  # Filtra por papéis (lista)
  scope :with_roles, lambda { |roles|
    unless roles.empty?
      where(:role_id => roles.flatten)
    end
  }

  # Filtra por palavra-chave (procura em User)
  scope :with_keyword, lambda { |keyword|
    if not keyword.empty? and keyword.size > 3
      where("users.first_name LIKE :keyword " + \
        "OR users.last_name LIKE :keyword " + \
        "OR users.login LIKE :keyword", {:keyword => "%#{keyword}%"}).
        include(:user).include(:user_space_associations).indluce(:space)
    end
  }

  scope :recent, lambda { where("created_at >= ?", 1.week.ago) }
  scope :approved, where(:state => 'approved')
  scope :invited, where(:state => 'invited')

  # Máquina de estados para moderação das dos usuários nos courses.
  acts_as_state_machine :initial => :waiting
  state :waiting
  state :invited, :enter => :send_course_invitation_notification
  # create_hierarchy_associations só é achamado no caso de convites
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

  # Verificar se há UCA com estado pending para um determinado usuário.
  # Opcionalmente pode-se passar o curso.
  def self.has_invitation_for?(user, course = nil)
    conditions = { :state => 'invited', :user_id => user }
    conditions[:course_id] = course unless course.nil?

    UserCourseAssociation.where(conditions).count > 0
  end

  def send_course_invitation_notification
    UserNotifier.course_invitation_notification(self.user, self.course).deliver
  end

  protected

  def create_hierarchy_associations
    self.course.create_hierarchy_associations(self.user) if self.invited?
  end
end

class UserCourseAssociation < CourseEnrollment
  belongs_to :user
  classy_enum_attr :role, :default => 'member'
  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy

  # Filtra por papéis (lista)
  scope :with_roles, lambda { |roles|
    unless roles.empty?
      where(:role => roles.flatten)
    end
  }

  # Filtra por palavra-chave (procura em User)
  scope :with_keyword, lambda { |keyword|
    if not keyword.empty? and keyword.size > 2
      where("users.first_name LIKE :keyword " + \
        "OR users.last_name LIKE :keyword " + \
        "OR users.login LIKE :keyword", {:keyword => "%#{keyword.to_s}%"}).
        includes(:user => [{:user_space_associations => :space}])
    end
  }

  scope :recent, lambda { where("created_at >= ?", 1.week.ago) }
  scope :approved, where(:state => 'approved')
  scope :invited, where(:state => 'invited')
  scope :waiting, where(:state => 'waiting')

  scope :last_accessed, lambda { |limit|
    where("last_accessed_at IS NOT NULL"). order("last_accessed_at DESC").
      limit(limit)
  }

  # Máquina de estados para moderação das dos usuários nos courses.
  aasm_column :state

  aasm_initial_state :waiting

  aasm_state :waiting, :enter => :send_pending_moderation_notification
  aasm_state :invited, :enter => :send_course_invitation_notification
  aasm_state :approved, :enter => :create_hierarchy_associations
  aasm_state :rejected
  aasm_state :failed

  aasm_event :invite do
    transitions :to => :invited, :from => [:waiting]
  end

  aasm_event :approve do
    transitions :to => :approved, :from => [:waiting]
  end

  aasm_event :accept do
    transitions :to => :approved, :from => [:invited]
  end

  aasm_event :reject do
    transitions :to => :rejected, :from => [:waiting]
  end

  aasm_event :deny do
    transitions :to => :rejected, :from => [:invited]
  end

  aasm_event :fail do
    transitions :to => :failed, :from => [:waiting]
  end

  validates_uniqueness_of :user_id, :scope => [:course_id, :type]

  def send_course_invitation_notification
    UserNotifier.delay(:queue => 'email').course_invitation(self.user, self.course)
  end

  def send_pending_moderation_notification
    if self.course.subscription_type.eql? 2
      self.notify_pending_moderation
    end
  end

  # Verifica se UserCourseAssociation é capaz de gerar log ou e-mail.
  def notificable?
    self.approved? && self.logs.empty?
  end

  # Notifica adimistradores do curso a respeito de moderações pendentes
  def notify_pending_moderation
    self.course.administrators.each do |admin|
      UserNotifier.delay(:queue => 'email').
        course_moderation_requested(course, admin, user)
    end
  end

  # Verifica se UserCourseAssociation é capaz de gerar log ou e-mail.
  def notificable?
    self.approved? && self.logs.empty?
  end

  protected

  def create_hierarchy_associations
    # Só deve criar as associações da hierarquia se o UCA existir no BD
    if !self.new_record? && (self.invited? || (has_environment? && self.waiting?))
      self.course.create_hierarchy_associations(self.user, self.role)
    end
  end

  def has_environment?
    !course.try(:environment).nil?
  end
end

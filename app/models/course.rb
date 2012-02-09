class Course < ActiveRecord::Base
  include ActsAsBillable

  # Apenas deve ser chamado na criação do segundo curso em diante
  after_create :create_user_course_association, :unless => "self.environment.nil?"

  belongs_to :environment
  has_many :spaces, :dependent => :destroy
  has_many :user_course_associations, :dependent => :destroy
  has_many :user_course_invitations, :dependent => :destroy
  belongs_to :owner, :class_name => "User", :foreign_key => "owner"
  has_many :users, :through => :user_course_associations
  has_many :approved_users, :through => :user_course_associations,
    :source => :user, :conditions => [ "user_course_associations.state = ?",
                                       'approved' ]
  has_many :pending_users, :through => :user_course_associations,
    :source => :user, :conditions => [ "user_course_associations.state = ?",
                                       'waiting' ]
  # environment_admins
  has_many :administrators, :through => :user_course_associations,
    :source => :user,
    :conditions => [ "user_course_associations.role = ? AND user_course_associations.state = ?",
                      3, 'approved' ]
  # teachers
  has_many :teachers, :through => :user_course_associations,
    :source => :user,
    :conditions => [ "user_course_associations.role = ? AND user_course_associations.state = ?",
                      5, 'approved' ]
  # tutors
  has_many :tutors, :through => :user_course_associations,
    :source => :user,
    :conditions => [ "user_course_associations.role = ? AND user_course_associations.state = ?",
                      6, 'approved' ]
  # students (member)
  has_many :students, :through => :user_course_associations,
    :source => :user,
    :conditions => [ "user_course_associations.role = ? AND user_course_associations.state = ?",
                      2, 'approved' ]

  # new members (form 1 week ago)
  has_many :new_members, :through => :user_course_associations,
    :source => :user,
    :conditions => [ "user_course_associations.state = ? AND user_course_associations.updated_at >= ?", 'approved', 1.week.ago]

  has_many :teachers_and_tutors, :through => :user_course_associations,
    :source => :user, :select => 'users.id',
    :conditions => [ "(user_course_associations.role = ? OR user_course_associations.role = ?) AND user_course_associations.state = ?", 6, 5, 'approved']

  has_and_belongs_to_many :audiences

  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy
  has_many :statuses, :as => :statusable, :order => "updated_at DESC",
    :dependent => :destroy

  scope :published, where(:published => 1)
  scope :of_environment, lambda { |environmnent_id|
    where(:environment_id => environmnent_id)
  }

  scope :with_audiences, lambda { |audiences_ids|
    joins(:audiences).where('audiences_courses.audience_id IN (?)',
                             audiences_ids).group(:id)
  }

  scope :user_behave_as_administrator, lambda { |user_id|
    joins(:user_course_associations).
      where("user_course_associations.user_id = ? AND user_course_associations.role = ?",
             user_id, 3)
  }

  scope :user_behave_as_teacher, lambda { |user_id|
    joins(:user_course_associations).
      where("user_course_associations.user_id = ? AND user_course_associations.role = ?",
              user_id, 5)
  }

  scope :user_behave_as_tutor, lambda { |user_id|
    joins(:user_course_associations).
      where("user_course_associations.user_id = ? AND user_course_associations.role = ?",
              user_id, 6)
  }

  scope :user_behave_as_student, lambda { |user_id|
    joins(:user_course_associations).
      where("user_course_associations.user_id = ? AND user_course_associations.role = ? AND user_course_associations.state = ?",
              user_id, 2, 'approved')
  }

  attr_protected :owner, :published, :environment

  acts_as_taggable

  validates_presence_of :name, :path
  validates_uniqueness_of :name, :path, :scope => :environment_id
  validates_length_of :name, :maximum => 60
  validates_length_of :description, :maximum => 250, :allow_blank => true
  validates_format_of :path, :with => /^[-_A-Za-z0-9]*$/

  # Sobreescrevendo ActiveRecord.find para adicionar capacidade de buscar por path do Space
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_path(*args)
    else
      super
    end
  end

  def to_param
    return self.id.to_s if self.path.empty?
    self.path
  end

  # Muda papeis deste ponto para baixo na hieararquia
  def change_role(user, role)
    membership = user.user_course_associations.
                   where(:course_id => self.id).first
    membership.update_attributes({:role => role})

    # alterando o papel do usuário no license atual
    license = user.get_open_license_with(self)
    if license
      license.role = role
      license.save
    end

    user.user_space_associations.where(:space_id => self.spaces).
      includes(:space).each do |membership|
        membership.space.change_role(user, role)
      end
  end

  def create_user_course_association
    self.environment.administrators.each do |env_admin|
      user_course =
        UserCourseAssociation.create(:user => env_admin,
                                     :course => self,
                                     :role => Role[:environment_admin])
      user_course.approve!
    end
  end

  def join(user, role = Role[:member])
    association = UserCourseAssociation.create(:user_id => user.id,
                                               :course_id => self.id,
                                               :role => role)

    association = user.get_association_with(self) if association.new_record?

    if self.subscription_type.eql? 1 and association.waiting?  # Todos podem participar, sem moderação
      association.approve!
    elsif association.invited?
      association.accept!
    end
  end

  def unjoin(user)
    course_association = user.get_association_with(self)
    course_association.destroy

    # Atualizando license atual para setar o period_end
    set_period_end(user)

    self.spaces.each do |space|
      space_association = user.get_association_with(space)
      space_association.destroy

      space.subjects.each do |subject|
        enrollment = user.get_association_with subject
        enrollment.destroy if enrollment
      end
    end
  end

  def create_hierarchy_associations(user, role = Role[:member])
    # FIXME mudar estado do user_course_association para approved
    # Cria as associações no Environment do Course e em todos os seus Spaces.
    UserEnvironmentAssociation.create(:user_id => user.id,
                                      :environment_id => self.environment.id,
                                      :role => role)


    self.create_license(user, role)
    self.spaces.each do |space|
      #FIXME tirar status quando remover moderacao de space
      UserSpaceAssociation.create(:user_id => user.id,
                                  :space_id => space.id,
                                  :role => role,
                                  :status => "approved")

      # Cria as associações com os subjects
      space.subjects.each do |subject|
        subject.enroll(user, role)
      end
    end
  end

  # Verifica se o usuário em questão está esperando aprovação num determinado
  # Course
  def waiting_approval?(user)
    assoc = user.get_association_with self
    return false if assoc.nil?
    assoc.waiting?
  end

  # Verifica se o usuário em questão teve a sua participação rejeitada em um
  # determinado Course
  def rejected_participation?(user)
    assoc = user.get_association_with self
    return false if assoc.nil?
    assoc.rejected?
  end

  # Método de alto nível que convida um determinado usuário para o curso.
  # - Caso o usuário não faça parte do curso uma UCA será criada com o estado
  #   invited.
  # - Caso o usuário já faça parte do curso, nada irá acontecer
  # - Caso o usuário esteja na lista de moderação, seu estado será mudado para
  #   invited
  # - Caso o usuário já tenha sido convidado e não tenha aceito o convite, um
  #   novo e-mail será enviado.
  def invite(user)
    assoc = self.user_course_associations.create(:user => user,
                                                 :role => Role[:member])
    if assoc.new_record?
      assoc = user.get_association_with(self)
      # Se já foi convidado, apenas reenvia o e-mail
      if assoc.invited?
        assoc.send_course_invitation_notification
        assoc.updated_at = Time.now
        assoc.save
      elsif assoc.waiting?
        assoc.approve!
      end
    else
      assoc.invite!
    end

    assoc
  end

  # Método de alto nível que convida um determinado usuário para o curso
  # através do e-mail.
  # - Caso o e-mail já tenha sido convidado e não tenha aceito o convite, um
  #   novo e-mail será enviado.
  def invite_by_email(email)
    u =  User.find_by_email(email)
    if u
      invitation = self.invite(u)
    else
      invitation = self.user_course_invitations.create(:email => email)
      # Se já foi convidado, apenas reenvia o e-mail
      if invitation.new_record?
        invitation = self.user_course_invitations.with_email(email).first
        # Caso o e-mail seja mal-formado, não vai salvar e será ignorado.
        unless invitation.nil?
          invitation.send_external_user_course_invitation
          invitation.updated_at = Time.now
          invitation.save
        end
      else
        invitation.invite!
      end
    end
    invitation
  end

  # Indica se o curso possui convites para usuários não registrados
  def invited?(email)
    self.user_course_invitations.find_by_email(email)
  end

  def can_add_entry?
    self.approved_users.count < self.plan.members_limit
  end

  def plan
    # TODO rever este código
    self.plans.order("created_at DESC").limit(1).first
  end

  protected

  # Cria licença passando com parâmetro o usuário que acaba de se matricular e o
  # papel que desempenha
  def create_license(user, role)
    if self.environment.plan
      invoice = self.environment.plan.invoice
      if invoice and invoice.type = "LicensedInvoice"
        invoice.licenses << License.create(:name => user.display_name,
                                           :login => user.login,
                                           :email => user.email,
                                           :period_start => DateTime.now,
                                           :role => role,
                                           :invoice => invoice,
                                           :course => self)
      end
    end
  end

  # Seta o period_end de License quando o usuário é desmatriculado ou se desmatricula
  def set_period_end(user)
    if self.environment.plan
      invoice = self.environment.plan.invoice
      if invoice and invoice.type = "LicensedInvoice"
        license = user.get_open_license_with(self)
        license.period_end = DateTime.now
        license.save
      end
    end
  end

end

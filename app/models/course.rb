class Course < ActiveRecord::Base

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
    :conditions => [ "user_course_associations.role_id = ? AND user_course_associations.state = ?",
                      3, 'approved' ]
  # teachers
  has_many :teachers, :through => :user_course_associations,
    :source => :user,
    :conditions => [ "user_course_associations.role_id = ? AND user_course_associations.state = ?",
                      5, 'approved' ]
  # tutors
  has_many :tutors, :through => :user_course_associations,
    :source => :user,
    :conditions => [ "user_course_associations.role_id = ? AND user_course_associations.state = ?",
                      6, 'approved' ]
  # students (member)
  has_many :students, :through => :user_course_associations,
    :source => :user,
    :conditions => [ "user_course_associations.role_id = ? AND user_course_associations.state = ?",
                      2, 'approved' ]

  # new members (form 1 week ago)
  has_many :new_members, :through => :user_course_associations,
    :source => :user,
    :conditions => [ "user_course_associations.state = ? AND user_course_associations.updated_at >= ?", 'approved', 1.week.ago]

  has_and_belongs_to_many :audiences
  has_one :quota, :dependent => :destroy, :as => :billable
  has_one :plan, :as => :billable

  scope :of_environment, lambda { |environmnent_id|
    where(:environment_id => environmnent_id)
  }

  scope :with_audiences, lambda { |audiences_ids|
    joins(:audiences).where('audiences_courses.audience_id IN (?)',
                             audiences_ids).group(:id)
  }

  scope :user_behave_as_administrator, lambda { |user_id|
    joins(:user_course_associations).
      where("user_course_associations.user_id = ? AND user_course_associations.role_id = ?",
             user_id, 3)
  }

  scope :user_behave_as_teacher, lambda { |user_id|
    joins(:user_course_associations).
      where("user_course_associations.user_id = ? AND user_course_associations.role_id = ?",
              user_id, 5)
  }

  scope :user_behave_as_tutor, lambda { |user_id|
    joins(:user_course_associations).
      where("user_course_associations.user_id = ? AND user_course_associations.role_id = ?",
              user_id, 6)
  }

  scope :user_behave_as_student, lambda { |user_id|
    joins(:user_course_associations).
      where("user_course_associations.user_id = ? AND user_course_associations.role_id = ? AND user_course_associations.state = ?",
              user_id, 2, 'approved')
  }

  attr_protected :owner, :published, :environment

  acts_as_taggable

  validates_presence_of :name, :path
  validates_uniqueness_of :name, :path, :scope => :environment_id
  validates_length_of :name, :maximum => 60
  validates_length_of :description, :maximum => 250, :allow_blank => true
  validates_format_of :path, :with => /^[-_.A-Za-z0-9]*$/
  validate :length_of_tags

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

  def permalink
    "#{Redu::Application.config.url}/#{self.environment.path}/cursos/#{self.path}"
  end

  def can_be_published?
    self.spaces.published.size > 0
  end

  # Muda papeis deste ponto para baixo na hieararquia
  def change_role(user, role)
    membership = user.user_course_associations.
                   where(:course_id => self.id).first
    membership.update_attributes({:role_id => role.id})

    user.user_space_associations.where(:space_id => self.spaces).
      include(:space).each do |membership|
        membership.space.change_role(user, role)
      end
  end

  # Verifica se o path escolhido para o Course já é utilizado por outro
  # no mesmo Environment. Caso seja, um novo path é gerado.
  def verify_path!(environment_id)
    path  = self.path
    if Course.where("environment_id = ? AND path = ?",
                      environment_id, self.path).all
      self.path += '-' + SecureRandom.hex(1)

      # Mais uma tentativa para utilizar um path não existente.
      return if Course.where("environment_id = ? AND path = ?",
                               environment_id, self.path).empty?
      self.path = path + '-' + SecureRandom.hex(1)
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

  def length_of_tags
    tags_str = ""
    self.tags.each {|t|  tags_str += " " + t.name }
    self.errors.add(:tags, :too_long.l) if tags_str.length > 111
  end

  def join(user, role = Role[:member])
    association = UserCourseAssociation.create(:user_id => user.id,
                                               :course_id => self.id,
                                               :role_id => role.id)

    if self.subscription_type.eql? 1 # Todos podem participar, sem moderação
      association.approve!
      self.create_hierarchy_associations(user, role)
    end
  end

  def unjoin(user)
    course_association = user.get_association_with(self)
    course_association.destroy

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
                                      :role_id => role.id)
    self.spaces.each do |space|
      #FIXME tirar status quando remover moderacao de space
      UserSpaceAssociation.create(:user_id => user.id,
                                  :space_id => space.id,
                                  :role_id => role.id,
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
  # - Caso o usuário já faça parte do curso, nada irá acontece
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
        assoc.updated_at = ""; assoc.save # Para atualizar o updated_at
        return assoc
      end
    end

    assoc.invite!
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
          invitation.updated_at = ""; invitation.save # Para atualizar o updated_at
        end
      end
    end
    invitation
  end

  # Indica se o curso possui convites para usuários não registrados
  def invited?(email)
    self.user_course_invitations.find_by_email(email)
  end

  # Retorna o percentual de espaço ocupado por files
  def percentage_quota_file
    if self.quota.files >= self.plan.file_storage_limit
      100
    else
      (self.quota.files * 100.0) / self.plan.file_storage_limit
    end
  end

  # Retorna o percentual de espaço ocupado por arquivos multimedia
  def percentage_quota_multimedia
    if self.quota.multimedia >= self.plan.video_storage_limit
      100
    else
      ( self.quota.multimedia * 100.0 ) / self.plan.video_storage_limit
    end
  end

  # Retorna o percentual de membros do curso
  def percentage_quota_members
    if self.users.count >= self.plan.members_limit
      100
    else
      ( self.users.count * 100.0 )/ self.plan.members_limit
    end
  end

  def can_add_entry?
    self.approved_users.count < self.plan.members_limit
  end

end

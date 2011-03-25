class Course < ActiveRecord::Base

  # Apenas deve ser chamado na criação do segundo curso em diante
  after_create :create_user_course_association, :unless => "self.environment.nil?"
  after_create :setup_quota

  belongs_to :environment
  has_many :spaces, :dependent => :destroy
  has_many :user_course_associations, :dependent => :destroy
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

  has_many :invitations, :as => :inviteable, :dependent => :destroy
  has_and_belongs_to_many :audiences
  has_one :quota, :dependent => :destroy, :as => :billable
  has_one :plan, :as => :billable

  named_scope :of_environment, lambda { |environmnent_id|
   { :conditions => {:environment_id => environmnent_id} }
  }
  named_scope :with_audiences, lambda { |audiences_ids|
    {:joins => :audiences,
      :conditions => ['audiences_courses.audience_id IN (?)',
                        audiences_ids],
      :group => :id }
  }
  named_scope :user_behave_as_administrator, lambda { |user_id|
    { :joins => :user_course_associations,
      :conditions => ["user_course_associations.user_id = ? AND user_course_associations.role_id = ?",
                        user_id, 3] }
  }
  named_scope :user_behave_as_teacher, lambda { |user_id|
    { :joins => :user_course_associations,
      :conditions => ["user_course_associations.user_id = ? AND user_course_associations.role_id = ?",
                        user_id, 5] }
  }
  named_scope :user_behave_as_tutor, lambda { |user_id|
    { :joins => :user_course_associations,
      :conditions => ["user_course_associations.user_id = ? AND user_course_associations.role_id = ?",
                        user_id, 6] }
  }
  named_scope :user_behave_as_student, lambda { |user_id|
    { :joins => :user_course_associations,
      :conditions => ["user_course_associations.user_id = ? AND user_course_associations.role_id = ? AND user_course_associations.state = ?",
                        user_id, 2, 'approved'] }
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
    "#{AppConfig.community_url}/#{self.environment.path}/cursos/#{self.path}"
  end

  def can_be_published?
    self.spaces.published.size > 0
  end

  # Muda papeis deste ponto para baixo na hieararquia
  def change_role(user, role)
    membership = user.user_course_associations.find(:first,
                    :conditions => {:course_id => self.id})
    membership.update_attributes({:role_id => role.id})

    user.user_space_associations.find(:all,
                     :conditions => {:space_id => self.spaces},
                     :include => [:space]).each do |membership|
      membership.space.change_role(user, role)
    end
  end

  # Verifica se o path escolhido para o Course já é utilizado por outro
  # no mesmo Environment. Caso seja, um novo path é gerado.
  def verify_path!(environment_id)
    path  = self.path
    if Course.all(:conditions => ["environment_id = ? AND path = ?",
                  environment_id, self.path])
      self.path += '-' + SecureRandom.hex(1)

      # Mais uma tentativa para utilizar um path não existente.
      return if Course.all(:conditions => ["environment_id = ? AND path = ?",
                               environment_id, self.path]).empty?
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
      end
  end

  # Cria Quota para o Course
  def setup_quota
    self.create_quota
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
end

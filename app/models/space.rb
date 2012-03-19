class Space < ActiveRecord::Base
  # Representa uma disciplina de ensino. O objetivo principal do Space é agrupar
  # objetos de ensino (Lecture e Subject) e promover a interação de muitos
  # para muitos entre os usuários (Status e Forum).
  #
  # Além disso, o Space fornece mecanismos para compartilhamento de arquivos
  # (MyFile).

  # CALLBACKS
  after_create :create_root_folder
  after_create :create_space_association_for_users_course

  # ASSOCIATIONS
  belongs_to :course

  # USERS
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
  has_many :user_space_associations, :dependent => :destroy
  has_many :users, :through => :user_space_associations,
    :conditions => ["user_space_associations.status LIKE 'approved'"]
  # environment_admins
  has_many :administrators, :through => :user_space_associations,
    :source => :user,
    :conditions => \
    [ "user_space_associations.role = ? AND user_space_associations.status = ?",
      3, 'approved' ]
  # teachers
  has_many :teachers, :through => :user_space_associations,
    :source => :user,
    :conditions => \
    [ "user_space_associations.role = ? AND user_space_associations.status = ?",
      5, 'approved' ]
  # tutors
  has_many :tutors, :through => :user_space_associations,
    :source => :user,
    :conditions => \
    [ "user_space_associations.role = ? AND user_space_associations.status = ?",
      6, 'approved' ]
  # students (member)
  has_many :students, :through => :user_space_associations,
    :source => :user,
    :conditions => \
    [ "user_space_associations.role = ? AND user_space_associations.status = ?",
      2, 'approved' ]

 # new members (form 1 week ago)
  has_many :new_members, :through => :user_space_associations,
    :source => :user,
    :conditions => [ "user_space_associations.status = ? " + \
                     "AND user_space_associations.updated_at >= ?",
                     'approved', 1.week.ago]
  has_many :folders, :dependent => :destroy
  has_many :subjects, :dependent => :destroy,
    :conditions => { :finalized => true }
  has_one :root_folder, :class_name => 'Folder', :foreign_key => 'space_id'
  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy
  has_many :statuses, :as => :statusable, :order => "updated_at DESC",
    :dependent => :destroy

  scope :of_course, lambda { |course_id| where(:course_id => course_id) }
  scope :published, where(:published => true)
  scope :teachers, joins(
        :user_space_associations).where("user_space_associations.role = ?", 5)

  # ACCESSORS
  attr_protected :owner, :removed, :lectures_count, :members_count,
                 :course_id, :published

  # PLUGINS
  acts_as_taggable
  has_attached_file :avatar, Redu::Application.config.paperclip

  # VALIDATIONS
  validates_presence_of :name
  validates_length_of :name, :maximum => 40

  def create_root_folder
    @folder = self.folders.create(:name => "root")
  end

  # Muda papeis neste ponto da hieararquia
  def change_role(user, role)
    membership = self.user_space_associations.where(:user_id => user.id).first
    membership.update_attributes({:role => role})
  end

  # Após a criação do space, todos os usuários do course ao qual
  # o space pertence tem que ser associados ao space
  def create_space_association_for_users_course

    course_users = UserCourseAssociation.where(:state => 'approved',
                                               :course_id => self.course)

    course_users.each do |assoc|
      UserSpaceAssociation.create({:user => assoc.user,
                                  :space => self,
                                  :status => "approved",
                                  :role => assoc.role})
    end

  end

  def myfiles
    Myfile.where("folder_id IN (?)", self.folders)
  end

  # Verifica se space está pronto para ser enviado por notificações
  def notificable?; true end

  # Envia notificação por e-mail de criação de Space para todos os usuários
  # do Course
  def notify_space_added
    if self.notificable?
      self.course.approved_users.each do |u|
        UserNotifier.space_added(u, self).deliver
      end
    end
  end

  def lectures_count
    self.subjects.select(:id).collect{ |subject| subject.lectures.count }.sum
  end

  def subjects_id
    self.subjects.collect{ |subject| subject.id }
  end
end

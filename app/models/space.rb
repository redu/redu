# -*- encoding : utf-8 -*-
class Space < ActiveRecord::Base
  include DestroySoon::ModelAdditions
  include SpaceSearchable
  include StatusService::BaseModelAdditions
  include StatusService::StatusableAdditions::ModelAdditions
  attr_writer :member_count

  # Representa uma disciplina de ensino. O objetivo principal do Space é agrupar
  # objetos de ensino (Lecture e Subject) e promover a interação de muitos
  # para muitos entre os usuários (Status e Forum).
  #
  # Além disso, o Space fornece mecanismos para compartilhamento de arquivos
  # (MyFile).

  # CALLBACKS
  after_create :create_root_folder
  after_commit :delay_create_space_association_for_users_course, on: :create

  # ASSOCIATIONS
  belongs_to :course

  # USERS
  belongs_to :owner , class_name: "User" , foreign_key: "user_id"
  has_many :user_space_associations, dependent: :destroy
  has_many :users, through: :user_space_associations
  # environment_admins
  has_many :administrators, through: :user_space_associations,
    source: :user, conditions: ["user_space_associations.role = ?", :environment_admin]
  # teachers
  has_many :teachers, through: :user_space_associations,
    source: :user, conditions: ["user_space_associations.role = ?", :teacher]
  # tutors
  has_many :tutors, through: :user_space_associations,
    source: :user, conditions: [ "user_space_associations.role = ?", :tutor]
  # students (member)
  has_many :students, through: :user_space_associations,
    source: :user, conditions: [ "user_space_associations.role = ?", :member]

 # new members (form 1 week ago)
  has_many :new_members, through: :user_space_associations,
    source: :user,
    conditions: ["user_space_associations.updated_at >= ?", 1.week.ago]
  has_many :folders, conditions: ["parent_id IS NULL"],
    dependent: :destroy
  has_many :folders_and_subfolders, class_name: "Folder",
    dependent: :destroy
  has_many :subjects, dependent: :destroy,
    conditions: { finalized: true }
  has_one :root_folder, class_name: 'Folder', foreign_key: 'space_id'
  has_many :logs, as: :logeable, order: "created_at DESC",
    dependent: :destroy
  has_many :statuses, as: :statusable, order: "updated_at DESC",
    dependent: :destroy
  has_many :canvas, as: :container, class_name: 'Api::Canvas'

  scope :of_course, lambda { |course_id| where(course_id: course_id) }
  scope :published, where(published: true)
  scope :teachers, joins(:user_space_associations).
    where("user_space_associations.role = ?", :teacher)

  # ACCESSORS
  attr_protected :owner, :removed, :lectures_count, :members_count,
                 :course_id, :published

  # PLUGINS
  acts_as_taggable
  has_attached_file :avatar, Redu::Application.config.paperclip

  # VALIDATIONS
  validates_presence_of :name
  validates_length_of :name, maximum: 40

  def create_root_folder
    @folder = self.folders.create(name: "root")
  end

  # Muda papeis neste ponto da hieararquia
  def change_role(user, role)
    membership = self.user_space_associations.where(user_id: user.id).first
    membership.update_attributes({role: role})
  end

  # Após a criação do space, todos os usuários do course ao qual
  # o space pertence tem que ser associados ao space
  def create_space_association_for_users_course
    course_users = UserCourseAssociation.where(state: 'approved',
                                               course_id: self.course).
                                               includes(:user)

    usas = course_users.collect do |assoc|
      UserSpaceAssociation.new(user: assoc.user,
                               space: self,
                               role: assoc.role)
    end
    UserSpaceAssociation.import(usas, validate: false)
  end

  # ver app/jobs/create_user_space_association_job.rb
  def delay_create_space_association_for_users_course
    job = CreateUserSpaceAssociationJob.new(space_id: self.id)
    Delayed::Job.enqueue(job, queue: 'hierarchy-associations')
  end

  def myfiles
    Myfile.where("folder_id IN (?)", self.folders_and_subfolders)
  end

  # Verifica se space está pronto para ser enviado por notificações
  def notificable?; true end

  # Envia notificação por e-mail de criação de Space para todos os usuários
  # do Course
  def notify_space_added
    if self.notificable?
      self.course.approved_users.each do |u|
        UserNotifier.delay(queue: 'email').space_added(u, self)
      end
    end
  end

  # ver app/jobs/notify_space_added_job.rb
  def delay_notify_space_added
    job = NotifySpaceAddedJob.new(space_id: self.id)
    Delayed::Job.enqueue(job, queue: 'email')
  end

  def lectures_count
    unless self.subjects.empty?
      Lecture.by_subjects(self.subjects).count
    end
  end

  def member_count
    @member_count || self.users.length
  end

  def subjects_id
    self.subjects.collect{ |subject| subject.id }
  end

  def students_id
    self.students.collect{ |student| student.id }
  end
end

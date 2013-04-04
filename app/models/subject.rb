class Subject < ActiveRecord::Base

  belongs_to :space
  belongs_to :owner, :class_name => "User", :foreign_key => :user_id
  has_many :lectures, :order => "position", :dependent => :destroy
  has_many :enrollments, :dependent => :destroy
  has_many :members, :through => :enrollments, :source => :user
  has_many :graduated_members, :through => :enrollments, :source => :user,
    :conditions => ["enrollments.graduated = 1"]
  has_many :teachers, :through => :enrollments, :source => :user,
    :conditions => ["enrollments.role = ?", :teacher]
  has_many :statuses, :as => :statusable, :order => "created_at DESC"
  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy
  has_many :asset_reports

  scope :recent, lambda { where('created_at > ?', 1.week.ago) }
  scope :visible, lambda { where('visible = ?', true) }

  attr_protected :owner, :finalized, :user_id

  validates_presence_of :name

  # Associa um usuário a vários subjects
  # - Retorna os enrollments criados
  def self.enroll(user, subjects, role = Role[:member])
    enrolls = subjects.collect do |subject|
      Enrollment.new(:subject => subject, :user => user, :role => role)
    end

    Enrollment.import(enrolls, :validate => false)
    enrollments = Enrollment.where('user_id = ? AND subject_id IN (?)', user, subjects).includes(:subject => [:lectures])
    enrollments.each { |e| e.create_assets_reports }
    enrollments
  end

  def recent?
    self.created_at > 1.week.ago
  end

  # Matricula o usuário com o role especificado. Retorna true ou false
  # dependendo do resultado
  def enroll(user, role = Role[:member])
    enrollment = self.enrollments.create(:user => user, :role => role)
    enrollment.valid?
    enrollment
  end

  # Desmatricula o usuário
  def unenroll(user)
    enrollment = user.get_association_with(self)
    enrollment.destroy
  end

  def enrolled?(user)
    !user.get_association_with(self).nil?
  end

  def change_lectures_order!(ids_order)
    ids_order.each_with_index do |id, i|
      unless !Lecture.exists?(id)
        lecture = Lecture.find(id)
        lecture.position = i + 1 # Para não ficar índice zero.
        lecture.save
      end
    end
  end

  def convert_lectureables!
    documents = self.lectures.includes(:lectureable).
                  where(:lectureable_type => ["Document"])
    documents.each { |d| d.lectureable.upload_to_scribd }

    seminars = self.lectures.includes(:lectureable).
                  where(:lectureable_type => ["Seminar"])
    seminars.each do |s|
      s.lectureable.convert! if s.lectureable.need_transcoding?
    end
  end

  def create_enrollment_associations
    self.space.user_space_associations.find_in_batches do |usas|
      enrollments = usas.collect do |usa|
        Enrollment.create(:user_id => usa.user_id, :subject => self,
                          :role => usa.role)
      end

      VisClient.notify_delayed("/hierarchy_notifications.json",
                               "enrollment", enrollments.compact)
    end
  end

  def graduated?(user)
    self.enrolled?(user) && user.get_association_with(self).graduated?
  end

  # Verifica se o módulo está pronto para ser publicado via
  # visão geral ou e-mail
  def notificable?
    self.finalized && self.visible && !self.logs.exists?
  end

  # Notifica todos alunos matriculados sobre a adição de Subject
  def notify_subject_added
    if notificable?
      self.space.users.all.each do|u|
        UserNotifier.delay(:queue => 'email').subject_added(u, self)
      end
    end
  end

  def self.destroy_subjects_unfinalized
    Subject.where(['created_at < ? AND finalized = 0', 1.day.ago]).each do |s|
      s.destroy
    end
  end
end

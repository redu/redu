class Subject < ActiveRecord::Base

  belongs_to :space
  belongs_to :owner, :class_name => "User", :foreign_key => :user_id
  has_many :lectures, :order => "position", :dependent => :destroy
  has_many :enrollments, :dependent => :destroy
  has_many :members, :through => :enrollments, :source => :user
  has_many :graduated_members, :through => :enrollments, :source => :user,
    :include => :student_profiles,
    :conditions => ["student_profiles.graduaded = 1"]
  has_many :teachers, :through => :enrollments, :source => :user,
    :conditions => ["enrollments.role = ?", 5] # Teacher
  has_many :statuses, :as => :statusable, :order => "created_at DESC"
  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy

  scope :recent, lambda { where('created_at > ?', 1.week.ago) }
  scope :visible, lambda { where('visible = ?', true) }

  attr_protected :owner, :finalized

  validates_presence_of :title

  def recent?
    self.created_at > 1.week.ago
  end

  # Matricula o usuário com o role especificado. Retorna true ou false
  # dependendo do resultado
  def enroll(user, role = Role[:member])
    enrollment = self.enrollments.create(:user => user, :role => role)
    enrollment.valid?
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
    params_array = []
    self.space.user_space_associations.each do |users_space|
      enrollment = self.enrollments.create(:user => users_space.user,
                                           :subject => self,
                                           :role => users_space.role)
      if enrollment
        params_array << fill_params(enrollment)
      end
    end
    Delayed::Job.enqueue HierarchyNotificationJob.new(params_array)
  end

  def graduated?(user)
    self.enrolled?(user) and user.get_association_with(self).student_profile.graduaded?
  end

  # Verifica se o módulo está pronto para ser publicado via
  # visão geral ou e-mail
  def notificable?
    self.finalized && self.visible && !self.logs.exists?
  end

  # Notifica todos alunos matriculados sobre a adição de Subject
  def notify_subject_added
    if self.notificable?
      self.space.users.each { |u| UserNotifier.subject_added(u, self).deliver }
    end
  end

  protected

  def fill_params(enrollment)
    course = enrollment.subject.space.course
    params = {
      :user_id => enrollment.user_id,
      :type => "enrollment",
      :lecture_id => nil,
      :subject_id => enrollment.subject_id,
      :space_id => enrollment.subject.space.id,
      :course_id => course.id,
      :status_id => nil,
      :statusable_id => nil,
      :statusable_type => nil,
      :in_response_to_id => nil,
      :in_response_to_type => nil,
      :created_at => enrollment.created_at,
      :updated_at => enrollment.updated_at
    }
  end
end

class Lecture < ActiveRecord::Base
  require 'sortable'
  # Entidade polimórfica que representa o objeto de aprendizagem. Pode possuir
  # três especializações: Seminar, InteractiveClass e Page.

  after_create :delay_create_asset_report

  # ASSOCIATIONS
  has_many :statuses, :as => :statusable, :order => "updated_at DESC",
    :dependent => :destroy
  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy

  #FIXME Falta testar
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  has_many :asset_reports, :dependent => :destroy
  belongs_to :owner , :class_name => "User" , :foreign_key => "user_id"
  belongs_to :lectureable, :polymorphic => true, :dependent => :destroy
  belongs_to :subject

  accepts_nested_attributes_for :lectureable

  # SCOPES
  scope :unpublished, where(:published => false)
  scope :published, where(:published => true)
  scope :seminars, where("lectureable_type LIKE 'Seminar'")
  scope :iclasses, where("lectureable_type LIKE 'InteractiveClass'")
  scope :pages, where("lectureable_type LIKE 'Page'")
  scope :documents, where("lectureable_type LIKE 'Document'")
  scope :exercises, where("lectureable_type LIKE 'Exercise'")
  scope :exercises_editables, where("lectureable_type LIKE 'Exercise' and lectureable_id NOT IN (SELECT exercise_id FROM results)")
  scope :recent, lambda { where('created_at > ?', 1.week.ago) }
  scope :by_subjects, lambda { |subjects_id| where(:subject_id =>subjects_id) }
  scope :by_day, lambda { |day| where(:created_at =>(day..(day+1))) }

  attr_protected :owner, :published, :view_count, :removed, :is_clone

  # PLUGINS
  acts_as_taggable
  ajaxful_rateable :stars => 5
  has_attached_file :avatar, Redu::Application.config.paperclip
  sortable :scope => :subject_id

  # VALIDATIONS
  validates_presence_of :name
  validates_presence_of :lectureable
  validates_associated :lectureable #FIXME Não foi testado, pois vai ter accepts_nested

  # Friendly url
  def to_param
    "#{id}-#{name.parameterize}"
  end

  # Marca a lecture atual como done ou undone
  def mark_as_done_for!(user, done)
    asset_report = self.asset_reports.of_user(user).last
    asset_report.done = done
    asset_report.save
  end

  def done?(user)
    assets = asset_reports.of_user(user)
    return false if assets.length == 0
    assets.last.done?
  end

  def clone_for_subject!(subject_id)
    if self.lectureable.is_a?(Exercise)
      nested_attrs = { :questions => :alternatives }
    end

    clone = self.clone :include => { :lectureable => nested_attrs },
      :except => [:rating_average, :view_count, :position, :subject_id]

    clone.is_clone = true
    clone.subject = Subject.find(subject_id)
    clone.save
    clone
  end

  def refresh_students_profiles
    self.subject.enrollments.each(&:"update_grade!")
  end

  def recent?
    self.created_at > 1.week.ago
  end

  # Diz se a instância está pronta para ser divulgada via mural ou e-mail
  def notificable?
    self.subject.finalized && self.subject.visible
  end

  def build_lectureable(params)
    return if params[:_type].blank?

    begin
      klass = params.delete(:_type).constantize
    rescue NameError # Caso seja não seja um lectureable válido
      return nil
    end
    relation = klass.reflections[:lecture].try(:options)

    if relation && relation[:as] == :lectureable
      self.lectureable = klass.new(params)
    end
  end

  def make_sense?
    if lectureable && lectureable.is_a?(Exercise)
      unless lectureable.make_sense?
        errors.add("lectureable.general", lectureable.errors[:general])
        false
      else
        true
      end
    else
      true
    end
  end

  # Cria asset_report entre esta aula e todos os usuários matriculados no
  # subject.
  def create_asset_report
    enrollments = Enrollment.where(:subject_id => self.subject.id)

    reports = enrollments.collect do |enrollment|
      AssetReport.new(:subject => self.subject, :enrollment => enrollment,
                      :lecture => self)
    end
    AssetReport.import(reports, :validate => false,
                       :on_duplicate_key_update => [:done])

    enrollments.includes(:asset_reports).where('grade > 0').
      collect(&:update_grade!)
  end

  protected

  # ver app/jobs/create_asset_report_job.rb
  def delay_create_asset_report
    job = CreateAssetReportJob.new(:lecture_id => self.id)
    Delayed::Job.enqueue(job, :queue => 'general')
  end

end

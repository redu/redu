class Lecture < ActiveRecord::Base
  require 'sortable'
  # Entidade polimórfica que representa o objeto de aprendizagem. Pode possuir
  # três especializações: Seminar, InteractiveClass e Page.

  #
  after_create :create_asset_report

  # ASSOCIATIONS
  has_many :statuses, :as => :statusable, :order => "updated_at DESC",
    :dependent => :destroy
  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy

  #FIXME Falta testar
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  has_many :asset_reports, :dependent => :destroy
  has_many :student_profiles, :through => :asset_reports, :dependent => :destroy
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
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
  scope :related_to, lambda { |lecture|
    where("name LIKE ? AND id != ?", "%#{lecture.name}%", lecture.id)
  }
  scope :recent, lambda { where('created_at > ?', 1.week.ago) }


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

  def permalink
    "#{Redu::Application.config.url}/lectures/#{self.id.to_s}-#{self.name.parameterize}"
  end

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
    return false if assets.empty?

    asset_reports.of_user(user).last.done?
  end

  def clone_for_subject!(subject_id)
    clone = self.clone :include => :lectureable,
      :except => [:rating_average, :view_count, :position, :subject_id]
    clone.is_clone = true
    clone.subject = Subject.find(subject_id)
    clone.save
    clone
  end

  def refresh_students_profiles
    student_profiles = StudentProfile.where(:subject_id => self.subject.id)
    student_profiles.each do |student_profile|
      student_profile.update_grade!
    end
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

    klass = params.delete(:_type).constantize
    relation = klass.reflections[:lecture].try(:options)

    if relation && relation[:as] == :lectureable
      self.lectureable = klass.new(params)
    end
  end

  def build_question_and_alternative
    self.lectureable.questions.build
    self.lectureable.questions.first.alternatives.build
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

  protected
  def create_asset_report
    student_profiles = StudentProfile.where(:subject_id => self.subject.id)
    student_profiles.each do |student_profile|
      self.asset_reports << AssetReport.create(:subject => self.subject,
                                               :student_profile => student_profile)
      student_profile.update_grade!
    end
  end
end

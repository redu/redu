class Lecture < ActiveRecord::Base
  require 'sortable'
  # Entidade polimórfica que representa o objeto de aprendizagem. Pode possuir
  # três especializações: Seminar, InteractiveClass e Page.

  #
  after_create :create_asset_report

  # ASSOCIATIONS
  has_many :statuses, :as => :statusable, :dependent => :destroy
  #FIXME Falta testar
  has_many :currently_watching_users, :through => :logs, :source => :user,
     :conditions => ['statuses.created_at > ?', 10.minutes.ago]
  has_many :acess_key
  #FIXME Verificar se é realmente utilizado (não foi testado)
  has_many :resources,
    :class_name => "LectureResource", :as => :attachable, :dependent => :destroy
  has_many :acquisitions
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  has_many :annotations
  has_many :logs, :as => :logeable, :dependent => :destroy, :class_name => 'Status'
  has_many :asset_reports, :dependent => :destroy
  has_many :student_profiles, :through => :asset_reports, :dependent => :destroy
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
  belongs_to :lectureable, :polymorphic => true, :dependent => :destroy
  belongs_to :subject

  accepts_nested_attributes_for :resources,
    :reject_if => lambda { |a| a[:media].blank? },
    :allow_destroy => true

  # SCOPES
  scope :unpublished, where(:published => false)
  scope :published, where(:published => true)
  scope :seminars, where("lectureable_type LIKE 'Seminar'")
  scope :iclasses, where("lectureable_type LIKE 'InteractiveClass'")
  scope :pages, where("lectureable_type LIKE 'Page'")
  scope :documents, where("lectureable_type LIKE 'Document'")
  scope :limited, lambda { |num| limit(num) }
  scope :related_to, lambda { |lecture|
    where("name LIKE ? AND id != ?", "%#{lecture.name}%", lecture.id)
  }


  attr_protected :owner, :published, :view_count, :removed, :is_clone

  # PLUGINS
  acts_as_taggable
  ajaxful_rateable :stars => 5
  has_attached_file :avatar, Redu::Application.config.paperclip
  sortable :scope => :subject_id

  # VALIDATIONS
  validates_presence_of :name
  # FIXME Vai ter description?
  #validates_presence_of :description
  #validates_length_of :description, :within => 30..200
  validates_presence_of :lectureable
  validates_associated :lectureable #FIXME Não foi testado, pois vai ter accepts_nested

  # Dependendo do lectureable_type ativa um conjunto de validações diferente
  validation_group :step1,
    :fields => [:name, :description, :lectureable_type]
  validation_group :step2, :fields => [:lectureable]

  def permalink
    APP_URL + "/lectures/"+ self.id.to_s+"-"+self.name.parameterize
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

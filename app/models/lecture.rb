class Lecture < ActiveRecord::Base
  # Entidade polimórfica que representa o objeto de aprendizagem. Pode possuir
  # três especializações: Seminar, InteractiveClass e Page.

  # ASSOCIATIONS
  has_many :statuses, :as => :statusable, :dependent => :destroy
  has_many :acess_key
  #FIXME Verificar se é realmente utilizado (não foi testado)
  has_many :resources,
    :class_name => "LectureResource", :as => :attachable, :dependent => :destroy
  has_many :acquisitions
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  has_many :annotations
  has_many :logs, :as => :logeable, :dependent => :destroy, :class_name => 'Status'
  has_one :subject, :through => :asset, :dependent => :destroy
  has_one :asset, :as => :assetable, :dependent => :destroy
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
  belongs_to :lectureable, :polymorphic => true, :dependent => :destroy
  belongs_to :lazy_asset

  accepts_nested_attributes_for :resources,
    :reject_if => lambda { |a| a[:media].blank? },
    :allow_destroy => true

  # NAMED SCOPES
  named_scope :published,
    :conditions => ["published = true"],
    :include => :owner, :order => 'created_at DESC'
  named_scope :seminars,
    :conditions => ["lectureable_type LIKE 'Seminar' AND published = true"],
    :include => :owner, :order => 'created_at DESC'
  named_scope :iclasses,
    :conditions => ["lectureable_type LIKE 'InteractiveClass' AND published = true"],
    :include => :owner, :order => 'created_at DESC'
  named_scope :pages,
    :conditions => ["lectureable_type LIKE 'Page' AND published = true"],
    :include => :owner, :order => 'created_at DESC'
  named_scope :documents,
    :conditions => ["lectureable_type LIKE 'Document' AND published = true"],
    :include => :owner, :order => 'created_at DESC'
  named_scope :limited, lambda { |num| { :limit => num } }

  attr_protected :owner, :published, :view_count, :removed, :is_clone

  # PLUGINS
  acts_as_taggable
  ajaxful_rateable :stars => 5
  has_attached_file :avatar, PAPERCLIP_STORAGE_OPTIONS

  # VALIDATIONS
  validates_presence_of :name
  validates_presence_of :description
  validates_length_of :description, :within => 30..200
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

  #FIXME chamar isso num validate_on_create
  def only_one_asset_per_lazy_asset?
    Asset.count(:conditions => {:lazy_asset_id => self.lazy_asset}) <= 0
  end

end

class Lecture < ActiveRecord::Base
  # Entidade polimórfica que representa o objeto de aprendizagem. Pode possuir
  # três especializações: Seminar, InteractiveClass e Page.

  # ASSOCIATIONS
  has_many :statuses, :as => :statusable, :dependent => :destroy
  has_many :acess_key
  has_many :resources,
    :class_name => "LectureResource", :as => :attachable, :dependent => :destroy
  has_many :acquisitions
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  has_many :annotations
  has_many :logs, :as => :logeable, :dependent => :destroy, :class_name => 'Status'
  has_many :assets, :as => :assetable
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
  belongs_to :lectureable, :polymorphic => true, :dependent => :destroy
  belongs_to :simple_category
  belongs_to :subject, :dependent => :destroy
  belongs_to :lazy_asset

  accepts_nested_attributes_for :resources,
    :reject_if => lambda { |a| a[:media].blank? },
    :allow_destroy => true

  # NAMED SCOPES
  named_scope :published,
    :conditions => ["state LIKE 'approved' AND public = true"],
    :include => :owner, :order => 'created_at DESC'
  named_scope :seminars,
    :conditions => ["state LIKE 'approved' AND lectureable_type LIKE 'Seminar' AND public = true"],
    :include => :owner, :order => 'created_at DESC'
  named_scope :iclasses,
    :conditions => ["lectureable_type LIKE 'InteractiveClass' AND public = true"],
    :include => :owner, :order => 'created_at DESC'
  named_scope :pages,
    :conditions => ["lectureable_type LIKE 'Page' AND public = true"],
    :include => :owner, :order => 'created_at DESC'
  named_scope :limited, lambda { |num| { :limit => num } }

  # PLUGINS
  acts_as_taggable
  ajaxful_rateable :stars => 5
  has_attached_file :avatar, PAPERCLIP_STORAGE_OPTIONS

  # Máquina de estados para moderação do Redu.
  # O estados do processo de transcoding estao em Seminar
  acts_as_state_machine :initial => :waiting
  state :waiting
  state :approved
  state :rejected

  event :approve do
    transitions :from => :waiting, :to => :approved
  end

  event :reject do
    transitions :from => :waiting, :to => :rejected
  end

  # VALIDATIONS
  validates_presence_of :name, :lazy_asset
  validates_presence_of :description
  validates_length_of :description, :within => 30..200
  validates_presence_of :simple_category
  validates_presence_of :lectureable_type
  validates_associated :lectureable

  # Dependendo do lectureable_type ativa um conjunto de validações diferente
  validation_group :step1,
    :fields => [:name, :description, :simple_category, :lectureable_type]
  validation_group :step2, :fields => [:lectureable]
  validation_group :step3, :fields => [:price]

  def permalink
    APP_URL + "/lectures/"+ self.id.to_s+"-"+self.name.parameterize
  end

  def currently_watching
    sql = "SELECT u.id, u.login, u.login_slug FROM users u, statuses s " + \
      "WHERE s.user_id = u.id "+ \
      "AND s.logeable_type LIKE 'Lecture' " + \
      "AND s.logeable_id = '#{self.id}' " + \
      "AND s.created_at > '#{Time.now.utc-10.minutes}'"

    User.find_by_sql(sql)
  end

  def thumb_url
    case self.lectureable_type

    when 'Seminar'
      if self.lectureable.external_resource_type == 'youtube'
        'http://i1.ytimg.com/vi/' + self.lectureable.external_resource + '/default.jpg'
      elsif self.lectureable.external_resource_type == 'upload'
        # Os thumbnails só são gerados após a conversão
        if self.lectureable.state == 'converted'
          File.join(File.dirname(self.lectureable.media.url), "thumb_0000.png")
        else
          #FIXME url hard coded
          '/images/missing_pic_space.png'
        end

      else
        'http://i1.ytimg.com/vi/0QQcj_tLIYo/default.jpg'
      end
    when 'InteractiveClass'
      if self.avatar_file_name
        self.avatar.url(:thumb)
      else
        # image_path("courses/missing_thumb.png")  # icone aula interativa
        #FIXME url hard coded
        '/images/courses/missing_interactive.png'
      end

    when 'Page'
      if self.avatar_file_name
        self.avatar.url(:thumb)
      else
        'http://i1.ytimg.com/vi/0QQcj_tLIYo/default.jpg'
      end
    end
  end

  def has_annotations_by(user)
    Annotation.find(:first,
                    :conditions => ["lecture_id = ? AND user_id = ?", self.id, user.id])
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

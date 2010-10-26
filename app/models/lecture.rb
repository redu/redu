class Lecture < ActiveRecord::Base
  
  # VALIDATIONS
  validates_presence_of :name
  validates_presence_of :description
  validates_length_of   :description, :within => 30..200
  validates_presence_of :simple_category
  validates_presence_of :lectureable_type
  validates_associated :lectureable
  validation_group :step1, :fields=>[:name, :description, :simple_category, :lectureable_type]
  validation_group :step2, :fields=>[:lectureable]
  validation_group :step3, :fields=>[:price]
  
  # ASSOCIATIONS
  has_many :statuses, :as => :statusable, :dependent => :destroy
  has_many :acess_key
  has_many :resources, :class_name => "LectureResource", :as => :attachable, :dependent => :destroy
  has_many :acquisitions
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  has_many :annotations
  has_one :space_asset, :as => :asset, :dependent => :destroy
  has_one :space, :through => :space_asset#, :as => :asset
  has_one :lecture_subject, :as => :lectureable
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
  belongs_to :lectureable, :polymorphic => true, :dependent => :destroy
  belongs_to :asset, :polymorphic => true
  belongs_to :simple_category
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
  has_attached_file :avatar, {
    :styles => { :thumb => "100x100>", :nano => "24x24>",
    :default_url => "/images/:class/missing_pic.jpg"}
  }
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
  
  def go_to_moderation
    #FIXME esse metodo é usado em algum lugar?
    if self.published
      if (self.lectureable_type != 'Seminar' || self.lectureable_type != 'InteractiveClass')
        self.moderate!#FIXME
      else
        self.state = 'approved'
      end
    end
  end
  
  def permalink
    APP_URL + "/lectures/"+ self.id.to_s+"-"+self.name.parameterize
  end

  def currently_watching
    sql = "SELECT u.id, u.login, u.login_slug FROM users u, statuses s WHERE"
    sql += " s.user_id = u.id AND s.logeable_type LIKE 'Lecture' AND s.logeable_id = '#{self.id}'"
    sql +=" AND s.created_at > '#{Time.now.utc-10.minutes}'"
    
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
          '/images/missing_pic_school.png'
        end

      else
        'http://i1.ytimg.com/vi/0QQcj_tLIYo/default.jpg'
      end
    when 'InteractiveClass'
      if self.avatar_file_name
        self.avatar.url(:thumb)
      else
        # image_path("courses/missing_thumb.png")  # icone aula interativa
        '/images/courses/missing_interactive.png'
      end

    when 'Page'
      if self.avatar_file_name
        self.avatar.url(:thumb)
      else
        
        'http://i1.ytimg.com/vi/0QQcj_tLIYo/default.jpg'
      end
      #APP_URL + '/images/icon_doc_48.png' #FIXME
    end
  end
  
  def has_annotations_by(user)
    Annotation.find(:first, :conditions => ["lecture_id = ? AND user_id = ?", self.id, user.id])
  end
  
  def to_param #friendly url
    "#{id}-#{name.parameterize}"
  end

  def build_lectureable(params)
    puts ' oi'
    case self.lectureable_type
      when "Page"
      # se edicao pega ja existente, senao:
      self.lectureable = Page.new(:body => "teste")
    end
  end
end

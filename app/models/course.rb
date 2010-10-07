class Course < ActiveRecord::Base

  # PLUGINS
  acts_as_taggable
  ajaxful_rateable :stars => 5
  has_attached_file :avatar, {
    :styles => { :thumb => "100x100>", :nano => "24x24>", 
    :default_url => "/images/:class/missing_pic.jpg"}
  }

  # ASSOCIATIONS
  has_many :statuses, :as => :statusable
  has_many :acess_key
  has_many :resources, :class_name => "CourseResource", :as => :attachable
  has_many :acquisitions
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  has_many :annotations
  has_one :school_asset, :as => :asset
  has_one :school, :through => :school_asset#, :as => :asset
  has_one :course_subject, :as => :courseable
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
  belongs_to :courseable, :polymorphic => true
  belongs_to :asset, :polymorphic => true
  belongs_to :simple_category


  # NESTED
  #accepts_nested_attributes_for :page
  accepts_nested_attributes_for :resources,
    :reject_if => lambda { |a| a[:media].blank? },
    :allow_destroy => true

  # VALIDATIONS
  validates_presence_of :name
  validates_presence_of :description
  validates_length_of   :description, :within => 30..200
  validates_presence_of :simple_category
  validates_presence_of :courseable_type

  validates_associated :courseable

  validation_group :step1, :fields=>[:name, :description, :simple_category, :courseable_type]
  
  #validation_group :step2_interactive, :fields=>[:name, :description]
  validation_group :step2, :fields=>[:courseable]
  validation_group :step3, :fields=>[:price]

  named_scope :published,
    :conditions => ["state LIKE 'approved' AND public = true"], 
    :include => :owner, :order => 'created_at DESC'
  named_scope :seminars,
    :conditions => ["state LIKE 'approved' AND courseable_type LIKE 'Seminar' AND public = true"], 
    :include => :owner, :order => 'created_at DESC'
  named_scope :iclasses, 
    :conditions => ["courseable_type LIKE 'InteractiveClass' AND public = true"], 
    :include => :owner, :order => 'created_at DESC'
  named_scope :pages, 
    :conditions => ["courseable_type LIKE 'Page' AND public = true"], 
    :include => :owner, :order => 'created_at DESC'
  named_scope :limited, lambda { |num| { :limit => num } }

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
      if (self.courseable_type != 'Seminar' || self.courseable_type != 'InteractiveClass')
        self.moderate!#FIXME
      else
        self.state = 'approved'
      end
    end
  end

  def permalink
    APP_URL + "/courses/"+ self.id.to_s+"-"+self.name.parameterize
  end


  def currently_watching
    sql = "SELECT u.id, u.login, u.login_slug FROM users u, statuses s WHERE"
    sql += " s.user_id = u.id AND s.logeable_type LIKE 'Course' AND s.logeable_id = '#{self.id}'"
    sql +=" AND s.created_at > '#{Time.now.utc-10.minutes}'"

    User.find_by_sql(sql)
  end

  def thumb_url
    case self.courseable_type

    when 'Seminar'
      if self.courseable.external_resource_type == 'youtube'
        'http://i1.ytimg.com/vi/' + self.courseable.external_resource + '/default.jpg'
      elsif self.courseable.external_resource_type == 'upload'
        # Os thumbnails só são gerados após a conversão
        if self.courseable.state == 'converted'
          File.join(File.dirname(self.courseable.media.url), "thumb_0000.png")
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
    Annotation.find(:first, :conditions => ["course_id = ? AND user_id = ?", self.id, user.id])
  end

  def to_param #friendly url
    "#{id}-#{name.parameterize}"
  end
  
  def build_courseable(params)
  puts ' oi'
  end
  
  def destroy
     self.courseable.destroy unless self.courseable.nil?
     super
    end
end

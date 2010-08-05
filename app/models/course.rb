class Course < ActiveRecord::Base

  # PLUGINS
  acts_as_commentable
  acts_as_taggable
  ajaxful_rateable :stars => 5
  
  # CALLBACKS
 # before_save :go_to_moderation
  
  # ASSOCIATIONS
  has_many :acess_key
  has_many :resources, :class_name => "CourseResource", :as => :attachable
  has_many :acquisitions
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  has_many :logs, :as => :logeable, :dependent => :destroy
  has_many :annotations
  has_one :school, :through => 'SchoolAssets'
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
  validates_presence_of :simple_category
  

  validation_group :step1, :fields=>[:name, :description, :simple_category]
  #validation_group :step2_interactive, :fields=>[:name, :description]
  # validation_group :step2_seminar, :fields=>[:media]
  validation_group :step3, :fields=>[:price]
  
  
  named_scope :seminars,:conditions => ["state LIKE 'approved' AND courseable_type LIKE 'Seminar' AND public = true"], :include => :owner, :order => 'created_at DESC'
  named_scope :iclasses, :conditions => ["courseable_type LIKE 'InteractiveClass' AND public = true"], :include => :owner, :order => 'created_at DESC'
  named_scope :pages, :conditions => ["courseable_type LIKE 'Page' AND public = true"], :include => :owner, :order => 'created_at DESC'
  named_scope :limited, lambda { |num| { :limit => num } }
  
   
  # Máquina de estados para moderação do Redu e conversão, caso vídeo aula.
  acts_as_state_machine :initial => :pending
  state :pending
  state :converting
  #state :converted, :enter => :upload, :after => :set_new_filename
  state :error
  
  state :waiting,:enter => :set_new_local_filename
  state :approved
  state :rejected
  
  event :approve do
    transitions :from => :waiting, :to => :approved
  end
  
  event :reject do
    transitions :from => :waiting, :to => :rejected
  end
  
  event :wait do
    transitions :from => :converting, :to => :waiting
  end
  
  event :moderate do
    transitions :from => :pending, :to => :waiting
  end
  
  event :convert do
    transitions :from => :pending, :to => :converting
  end
  
  event :converted do
    transitions :from => :converting, :to => :waiting
  end
  
  event :failure do
    transitions :from => :converting, :to => :error # TODO salvar estado de "erro" no bd
  end
  
  def go_to_moderation
    if self.published 
      if (self.courseable_type != 'Seminar' || self.courseable_type != 'InteractiveClass') 
      self.moderate!
    else
      self.state = 'approved'
      end
    end
  end
  
   def set_new_local_filename
     if self.courseable_type == 'Seminar' and self.courseable.external_resource_type == 'upload'
       self.courseable.update_attribute(:media_file_name, "#{self.courseable.id}.flv")
    end
  end
  
  
  def permalink
    APP_URL + "/courses/"+ self.id.to_s+"-"+self.name.parameterize
  end
  
  
  def can_be_deleted_by(user) #TODO verificar papel na escola
   (self.owner == user or user.admin?)
  end
  
  def currently_watching
    
    sql = "SELECT DISTINCT u.id, u.login, u.login_slug FROM users u, logs l WHERE"
    sql += " l.user_id = u.id AND l.logeable_type LIKE 'Course' AND l.logeable_id = '#{self.id}'"
    sql +=" AND l.created_at > '#{Time.now.utc-10.minutes}'"
    
    #TODO excluir o usuario atual?
    User.find_by_sql(sql)
  end
  
  def thumb_url
    case self.courseable_type
    
    when 'Seminar'
      if self.courseable.external_resource_type = 'youtube'
             'http://i1.ytimg.com/vi/' + self.courseable.external_resource + '/default.jpg' 
      else
       File.join(File.dirname(self.media.url), "#{self.id}128x96.jpg") 
     end
   when 'InteractiveClass'
     APP_URL + '/images/icon_ppt_48.png' #FIXME
     # icone aula interativa
   when 'Page'
     APP_URL + '/images/icon_doc_48.png' #FIXME
    end

  end
  
  def has_annotations_by(user)
    Annotation.find(:first, :conditions => ["course_id = ? AND user_id = ?", self.id, user.id])
  end
  
  
  def to_param #friendly url
    "#{id}-#{name.parameterize}"
  end
  
  # WIZARD
  
  
#  attr_writer :current_step
#
#  #validates_presence_of :shipping_name, :if => lambda { |o| o.current_step == "shipping" }
#  #validates_presence_of :billing_name, :if => lambda { |o| o.current_step == "billing" }
#  
#  def current_step
#    @current_step || steps.first
#  end
#  
#  def steps
#    %w[shipping billing confirmation]
#  end
#  
#  def next_step
#    self.current_step = steps[steps.index(current_step)+1]
#  end
#  
#  def previous_step
#    self.current_step = steps[steps.index(current_step)-1]
#  end
#  
#  def first_step?
#    current_step == steps.first
#  end
#  
#  def last_step?
#    current_step == steps.last
#  end
#  
#  def all_valid?
#    steps.all? do |step|
#      self.current_step = step
#      valid?
#    end
#  end
#  
  
  
end

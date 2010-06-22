class Course < ActiveRecord::Base
  SUPPORTED_VIDEOS = [ 'application/x-mp4',
    'video/mpeg',
    'video/quicktime',
    'video/x-la-asf',
    'video/x-ms-asf',
    'video/x-msvideo',
    'video/x-sgi-movie',
    'video/x-flv',
    'flv-application/octet-stream',
    'video/3gpp',
    'video/3gpp2',
    'video/3gpp-tt',
    'video/BMPEG',
    'video/BT656',
    'video/CelB',
    'video/DV',
    'video/H261',
    'video/H263',
    'video/H263-1998',
    'video/H263-2000',
    'video/H264',
    'video/JPEG',
    'video/MJ2',
    'video/MP1S',
    'video/MP2P',
    'video/MP2T',
    'video/mp4',
    'video/MP4V-ES',
    'video/MPV',
    'video/mpeg4',
    'video/mpeg4-generic',
    'video/nv',
    'video/parityfec',
    'video/pointer',
    'video/raw',
    'video/rtx' ] 
  
  SUPPORTED_AUDIO = ['audio/mpeg', 'audio/mp3']
  
  # PLUGINS
  acts_as_commentable
  acts_as_taggable
  ajaxful_rateable :stars => 5#, :dimensions => [:speed, :beauty, :price]
  
  # Acts as state machine plugin
  acts_as_state_machine :initial => :pending
  state :pending
  state :converting
  #state :converted, :enter => :upload, :after => :set_new_filename
  state :error
  
  state :waiting,:enter => :set_new_local_filename
  state :approved
  state :disapproved
  
  event :approve do
    transitions :from => :waiting, :to => :approved
  end
  
  event :disapprove do
    transitions :from => :waiting, :to => :disapproved
  end
  
  event :wait do
    transitions :from => :converting, :to => :waiting
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
  
  # ASSOCIATIONS
  has_and_belongs_to_many :subjects
  has_many :acess_key
  has_many :resources, :class_name => "CourseResource", :as => :attachable
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
  has_many :acquisitions
  has_attached_file :media
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  has_many :logs, :as => :logeable, :dependent => :destroy
  has_many :annotations
  
  # tipos de aula (como subclasses) 
  has_one :interactive_class, :dependent => :destroy
  has_one :page, :dependent => :destroy
  
  belongs_to :asset, :polymorphic => true
  belongs_to :category, :class_name => "Skill", :foreign_key => "skill_id"

  # Callbacks
  before_validation :enable_correct_validation_group
  
  validation_group :external, :fields => [:title, :description, :external_resource, :external_resource_type]
  validation_group :uploaded, :fields => [:title, :description, :media]
  
  validation_group :step1, :fields=>[:name, :description]
  #validation_group :step2_interactive, :fields=>[:name, :description]
  validation_group :step2_seminar, :fields=>[:media]
  validation_group :step3, :fields=>[:price]
  
  # VALIDATIONS
 # accepts_nested_attributes_for :price
  accepts_nested_attributes_for :resources, 
  	:reject_if => lambda { |a| a[:media].blank? },
  	:allow_destroy => true
  	
  validates_presence_of :name
  validates_presence_of :description
  validates_attachment_presence :media
  validates_attachment_content_type :media,
   :content_type => (SUPPORTED_VIDEOS + SUPPORTED_AUDIO)
  validates_attachment_size :media,
   :less_than => 50.megabytes
  
  
   named_scope :seminars,:conditions => ["state LIKE 'approved' AND course_type LIKE 'seminar' AND public = true"], :include => :owner, :order => 'created_at DESC'
   named_scope :iclasses, :conditions => ["course_type LIKE 'interactive' AND public = true"], :include => :owner, :order => 'created_at DESC'
   named_scope :pages, :conditions => ["course_type LIKE 'page' AND public = true"], :include => :owner, :order => 'created_at DESC'
    named_scope :limited, lambda { |num| { :limit => num } }

  
=begin  nao é usado mais, preço unico
  def self.price_of_acquisition(course_id)
    @course_prices = CoursePrice.find(:all,:conditions => ["course_id = ?",course_id])
    @course_prices.each do |course_price| 
      if course_price.key_number == 1
        @price = course_price.price
      end
    end 
    return @price
  end
=end   
  
  
  # This method is called from the controller and takes care of the converting
  def convert
    self.convert!
    puts self.state
    if video?    
      proxy = MiddleMan.worker(:converter_worker)
      proxy.enq_convert_course(:arg => self.id, :job_key => self.id) #TODO set timeout :timeout => ?
    else
      self.converted!
      #self.update_attribute(:state, "waiting")
    end
  end
  
  def video?
    SUPPORTED_VIDEOS.include?(self.media_content_type)
  end
  
  def audio?
    SUPPORTED_AUDIO.include?(self.media_content_type)
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
  
  # Inspects object attributes and decides which validation group to enable
  def enable_correct_validation_group
    if self.external_resource_type != "upload"
      self.enable_validation_group :external
    else
      self.enable_validation_group :uploaded
    end 
  end
  
  def type
    if video?
      self.media_content_type
    else
      self.external_resource_type
    end
  end
  
  def course_cannot_have_unpublished_resources
    msg = "Você não pode adicionar materiais não públicados à uma aula pública"
    errors.add(:main_resource, msg) if self.main_resource.published == false
    
    self.resources.each do |r|
      errors.add(:resource_ids, r.title + ": " + msg) if r.published == false
    end    
  end
  
  def set_new_local_filename
   # puts "set_new_local_filename"
    self.update_attribute(:media_file_name, "#{id}.flv")
  end
  
  def course_cannot_have_unpublished_resources
    msg = "Você não pode adicionar materiais não públicados à uma aula pública"
    errors.add(:main_resource, msg) if self.main_resource.published == false
    
    self.resources.each do |r|
      errors.add(:resource_ids, r.title + ": " + msg) if r.published == false
    end    
  end
  
  def thumb_url
    
    if self.type == 'youtube'
       'http://i1.ytimg.com/vi/' + self.external_resource + '/default.jpg' 
    else
      File.join(File.dirname(self.media.url), "#{self.id}128x96.jpg")
    end
  end
  
  def has_annotations_by(user)
    Annotation.find(:first, :conditions => ["course_id = ? AND user_id = ?", self.id, user.id])
  end
  
  
  def to_param #friendly url
    "#{id}-#{name.parameterize}"
  end
  
  
end

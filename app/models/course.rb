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
    state :converted, :after => :set_new_local_filename
    state :error
    
    state :waiting
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

    '''
    event :converted do
      transitions :from => :converting, :to => :waiting
    end
'''
    event :failure do
      transitions :from => :converting, :to => :error # TODO salvar estado de "erro" no bd
    end
      
  # ASSOCIATIONS
  has_and_belongs_to_many :subjects
  has_many :acess_key
  has_and_belongs_to_many :resources
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
  has_many :course_prices
  has_many :acquisitions
  has_attached_file :media
	has_many :favorites, :as => :favoritable, :dependent => :destroy
  has_many :logs, :as => :logeable, :dependent => :destroy

  # Callbacks
  before_validation :enable_correct_validation_group
  
  validation_group :external, :fields => [:title, :description, :external_resource, :external_resource_type]
  validation_group :uploaded, :fields => [:title, :description, :media]
  
  # VALIDATIONS
  accepts_nested_attributes_for :course_prices
  validates_presence_of :name
  validates_presence_of :description
  validates_attachment_presence :media
  validates_attachment_content_type :media,
   :content_type => (SUPPORTED_VIDEOS + SUPPORTED_AUDIO)
  validates_attachment_size :media,
   :less_than => 10.megabytes

  # This method is called from the controller and takes care of the converting
  def convert
    self.convert!
    if video?    
      proxy = MiddleMan.worker(:converter_worker)
      self.convert!
      proxy.enq_convert_course(:arg => self.id, :job_key => self.id) #TODO set timeout :timeout => ?
    else
			#self.converted!
      self.wait!
      #self.update_attribute(:state, "waiting")
    end
  end

  def video?
    SUPPORTED_VIDEOS.include?(self.media_content_type)
  end
  
  def audio?
  	SUPPORTED_AUDIO.include?(self.media_content_type)
 end
 
 def can_be_deleted_by(user)
    (self.owner == user or user.admin?)
 end
 
 def currently_watching
   
   sql = "SELECT DISTINCT u.id, u.login, u.login_slug FROM users u, logs l WHERE"
   sql += " l.user_id = u.id AND l.logeable_type LIKE 'course' AND l.logeable_id = '#{self.id}'"
   sql +=" AND l.created_at > '#{Time.now.utc-10.minutes}'"
   
   #TODO excluir o usuario atual?
    User.find_by_sql(sql)
  end
	
	# Inspects object attributes and decides which validation group to enable
	def enable_correct_validation_group
	  puts "enable_correct_validation_group", self.external_resource_type
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
    self.update_attribute(:media_file_name, "#{id}.flv")
  end
  
  def course_cannot_have_unpublished_resources
    msg = "Você não pode adicionar materiais não públicados à uma aula pública"
    errors.add(:main_resource, msg) if self.main_resource.published == false
    
      self.resources.each do |r|
        errors.add(:resource_ids, r.title + ": " + msg) if r.published == false
      end    
  end
  
  def self.price_of_acquisition(course_id)
  @course_prices = CoursePrice.find(:all,:conditions => ["course_id = ?",course_id])
  @course_prices.each do |course_price| 
    if course_price.key_number == 1
      @price = course_price.price
    end
  end 
  return @price
  end
  
  
end

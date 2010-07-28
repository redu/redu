class Seminar < ActiveRecord::Base
  
  #belongs_to :course
  has_one :course, :as => :courseable
  
  has_many :lesson, :as => :lesson
  
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
    'video/avi',
    'video/mpeg4-generic',
    'video/nv',
    'video/parityfec',
    'video/pointer',
    'video/raw',
    'video/rtx' ] 
    
     SUPPORTED_AUDIO = ['audio/mpeg', 'audio/mp3']
     
#     # Acts as state machine plugin
#  acts_as_state_machine :initial => :pending
#  state :pending
#  state :converting
#  #state :converted, :enter => :upload, :after => :set_new_filename
#  state :error
#  
#  state :waiting,:enter => :set_new_local_filename
#  state :approved
#  state :disapproved
#  
#  event :approve do
#    transitions :from => :waiting, :to => :approved
#  end
#  
#  event :disapprove do
#    transitions :from => :waiting, :to => :disapproved
#  end
#  
#  event :wait do
#    transitions :from => :converting, :to => :waiting
#  end
#  
#  event :convert do
#    transitions :from => :pending, :to => :converting
#  end
#  
#  event :converted do
#    transitions :from => :converting, :to => :waiting
#  end
#  
#  event :failure do
#    transitions :from => :converting, :to => :error # TODO salvar estado de "erro" no bd
#  end
#  
   has_attached_file :media
   
   
    # Callbacks
  before_validation :enable_correct_validation_group
  
  validation_group :external, :fields => [:external_resource, :external_resource_type] #title, description devem estar em course
  validation_group :uploaded, :fields => [:media]
  
   validates_attachment_presence :media
  validates_attachment_content_type :media,
   :content_type => (SUPPORTED_VIDEOS + SUPPORTED_AUDIO)
  validates_attachment_size :media,
   :less_than => 50.megabytes
   
   before_create :truncate_youtube_url
   
   
   def truncate_youtube_url
     if self.external_resource_type.eql?('youtube')
         capture = self.external_resource.scan(/youtube\.com\/watch\?v=([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/)[0][0]
              #puts capture.inspect # TODO criar validacao pra essa url
              self.external_resource = capture
     end
   end
   
   def convert
    self.convert!
    puts self.state
    if video?    
      proxy = MiddleMan.worker(:converter_worker)
      proxy.enq_convert_course(:arg => self.id, :job_key => self.id) #TODO set timeout :timeout => ?
    else
      self.course.converted!
      #self.update_attribute(:state, "waiting")
    end
  end
  
  def video?
    SUPPORTED_VIDEOS.include?(self.media_content_type)
  end
  
  def audio?
    SUPPORTED_AUDIO.include?(self.media_content_type)
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
  
  

  
  
end

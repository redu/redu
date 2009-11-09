class Resource < ActiveRecord::Base
  
  SUPPORTED_DOCUMENTS = ['application/pdf']
  
  SUPPORTED_AUDIO = [] # colocar mp3
  
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
      
  SUPPORTED_EXTERNAL_RESOURCES = ['youtube', 'vimeo', 'slideshare']
      
  acts_as_commentable
  
  ajaxful_rateable :stars => 5
  
  has_and_belongs_to_many :exams
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :subjects
  #has_and_belongs_to_many :workspaces
  belongs_to :owner, :class_name=> "User", :foreign_key => "owner"
  
	# validates_presence_of :name
	belongs_to :resourceable, :polymorphic => true
	has_attached_file :media, :if => :external_resource.nil?, :message => "has_attached_file"
	
	validates_presence_of :external_resource, :if => "media.nil?"
	validates_presence_of :title
  
 # validates_presence_of :name
  
   belongs_to :resourceable, :polymorphic => true
   
   has_attached_file :media
   
  # Paperclip Validations
	# paperclip validators doesn't accept conditional validations
	# so we need this hack.
  if :external_media.nil?
		validates_attachment_presence :media
		validates_attachment_content_type :media, 
			:content_type => (SUPPORTED_VIDEOS + SUPPORTED_AUDIO + SUPPORTED_DOCUMENTS)
		validates_attachment_size :media, 
			:less_than => 10.megabytes
 	end

  # Acts as state machine plugin
  acts_as_state_machine :initial => :pending, 
  	:if => :external_resource.nil?
  state :pending
  state :converting
  state :converted, :enter => :set_new_filename
  state :error
  
  event :convert do
    transitions :from => :pending, :to => :converting
  end
  
  event :converted do
    transitions :from => :converting, :to => :converted
  end
  
  event :failure do
    transitions :from => :converting, :to => :error # TODO salvar estado de "erro" no bd
  end
  
  # This method is called from the controller and takes care of the converting
  def convert
    self.convert!
    success = system(convert_command)
    if success && $?.exitstatus == 0
      self.converted!
     
    else
      self.failure!
    end
  end
	
  def video?
    SUPPORTED_VIDEOS.include?(self.media_content_type)
  end
  
  def type
  	if video? then
  		self.media_content_type
  	else
  		self.external_resource_type
  	end  	
  end
  
  def supported_external_resources
  	SUPPORTED_EXTERNAL_RESOURCES
  end
	
  protected
  
  def convert_command
    flv = File.join(File.dirname(media.path), "#{id}.flv")
    File.open(flv, 'w')
    
   # puts source.path
   # puts flv
   #  command = <<-end_command
   #  ffmpeg -i #{ RAILS_ROOT + '/public' + public_filename }  -ar 22050 -ab 32 -s 480x360 -vcodec flv -r 25 -qscale 8 -f flv -y #{ RAILS_ROOT + '/public' + public_filename + flv }
    

    command = <<-end_command
      ffmpeg -i "#{ media.path }" -ar 22050 -ab 32 -s 480x360 -vcodec flv -r 25 -qscale 8 -f flv -y "#{ flv }"
    end_command
    command.gsub!(/\s+/, " ")
  end

  # This update the stored filename with the new flash video file
  
  def set_new_filename
    self.update_attribute(:media_file_name, "#{self.id}.flv")
  end
  

  
  
end

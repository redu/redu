class Resource < ActiveRecord::Base

  SUPPORTED_DOCUMENTS = ['application/pdf']

  SUPPORTED_AUDIO = ['audio/mpeg', 'audio/mp3'] # colocar mp3

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

  SUPPORTED_EXTERNAL_RESOURCES = ['youtube']
  
  #has_one :clipping

	# Plugins
  acts_as_commentable
  acts_as_taggable
  ajaxful_rateable :stars => 5
  validation_group :external, :fields => [:title, :external_resource, :external_resource_type]
  validation_group :uploaded, :fields => [:title, :media]

	# Relationships
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :subjects
  has_and_belongs_to_many :exams
  belongs_to :owner, :class_name=> "User", :foreign_key => "owner"
  belongs_to :resourceable, :polymorphic => true

	# Callbacks
	before_validation :enable_correct_validation_group
	
	# Validations
  validates_presence_of :title, :external_resource_type, :external_resource
  validates_inclusion_of :external_resource_type, :in => SUPPORTED_EXTERNAL_RESOURCES
  has_attached_file :media
  validates_attachment_presence :media
  validates_attachment_content_type :media,
 	 :content_type => (SUPPORTED_VIDEOS + SUPPORTED_AUDIO + SUPPORTED_DOCUMENTS)
  validates_attachment_size :media,
 	 :less_than => 10.megabytes

	named_scope :published, :conditions => ['published = ?', true], :include => :owner
	
  # Acts as state machine plugin
  acts_as_state_machine :initial => :pending, :column => 'state'
  state :pending
  state :converting
  #state :converted, :enter => :upload, :after => :set_new_filename
  state :converted, :after => :set_new_local_filename
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
    if video?    
      proxy = MiddleMan.worker(:converter_worker)
      self.convert!
      proxy.enq_convert_resource(:arg => self.id, :job_key => self.id) #TODO set timeout :timeout => ?
    else
      puts "convert-else"
			self.converted!
			puts self.current_state
    end
    save
  end

  def video?
    SUPPORTED_VIDEOS.include?(self.media_content_type)
  end
  
  def audio?
  	SUPPORTED_AUDIO.include?(self.media_content_type)
  end

  def type
    if video?
      self.media_content_type
    else
      self.external_resource_type
    end
  end

  def supported_external_resources
    SUPPORTED_EXTERNAL_RESOURCES
  end

	# Inspects object attributes and decides which validation group enable
	def enable_correct_validation_group
	
		if self.external_resource_type != "upload"
			self.enable_validation_group :external
		else
			self.enable_validation_group :uploaded
		end 
		
	end
	
  
  protected

  def convert_command

    file = File.join(File.dirname(media.path), "#{id}.flv")
    File.open(file, 'w')

    command = <<-end_command
    ffmpeg -i "#{ media.path }" -ar 22050 -ab 32 -s 480x360 -vcodec flv -r 25 -qscale 8 -f flv -y "#{ file }"
    end_command
    command.gsub!(/\s+/, " ")

  end

  # Send the .flv to S3 and remove localy converted file
  def upload
    puts "upload"

    file_name = File.join(File.dirname(media.path), "#{id}.flv")
    puts file_name
    file = File.open(file_name, 'r')

    # Is that accessible in a built in way?
    config = YAML.load_file("#{RAILS_ROOT}/config/s3.yml")

    s3 = RightAws::S3Interface.new(config['development']['access_key_id'],
    config['development']['secret_access_key'])

    s3.put(config['development']['bucket'], "#{id}.flv", File.open(file_name), "x-amz-acl" => "public-read")
    File.delete(file_name)

  end

  # This update the stored filename with the new flash video file
  def set_new_filename
    # Is that accessible in a built in way?
    config = YAML.load_file("#{RAILS_ROOT}/config/s3.yml")
    self.update_attribute(:media_file_name, config['development']['url'] + "#{id}.flv")
  end

  def set_new_local_filename
    self.update_attribute(:media_file_name, "#{id}.flv")
  end

end


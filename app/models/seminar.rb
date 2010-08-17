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

  has_attached_file :media

  # Callbacks
  before_validation :enable_correct_validation_group
  before_create :truncate_youtube_url

  # Validations Groups - Usados para habilitar diferentes validacoes dependendo do tipo do arquivo.
  validation_group :external, :fields => [:external_resource, :external_resource_type]
  validation_group :uploaded, :fields => [:media]

  validates_attachment_presence :media
  validates_attachment_content_type :media,
    :content_type => (SUPPORTED_VIDEOS + SUPPORTED_AUDIO)
  validates_attachment_size :media,
    :less_than => 50.megabytes

  # Maquina de estados do processo de conversão
  acts_as_state_machine :initial => :waiting, :column => 'status'
  
  state :waiting
  state :converting, :enter => :notify_converting
  state :converted, :enter => [:set_new_file_name, :upload_to_s3]
  state :failed, :enter => :notify_failed
  
  event :convert do
    transitions :from => :waiting, :to => :converting
  end
  
  event :ready do
    transitions :from => :converting, :to => :converted
  end
  
  event :fail do
    transitions :from => :converting, :to => :fail
  end
  
  validate do |seminar|
    if seminar.external_resource_type.eql?('youtube')
      capture = seminar.external_resource.scan(/youtube\.com\/watch\?v=([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/)[0][0]
      seminar.errors.add_to_base("Link invalido") unless capture
    end
  end

  def truncate_youtube_url
    if self.external_resource_type.eql?('youtube')
      capture = self.external_resource.scan(/youtube\.com\/watch\?v=([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/)[0][0]
      # TODO criar validacao pra essa url
      self.external_resource = capture
    end
  end

  def convert
    #TODO 
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

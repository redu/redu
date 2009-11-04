class Resource < ActiveRecord::Base
  
  SUPPORTED_VIDEOS = ['video/quicktime', 'video/mpeg']
  
  acts_as_commentable
  
  ajaxful_rateable :stars => 5
  
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :subjects
  #has_and_belongs_to_many :workspaces
  
  
 # validates_presence_of :name
  
   belongs_to :resourceable, :polymorphic => true
   
   has_attached_file :media
   
  # Paperclip Validations
  validates_attachment_presence :media
  validates_attachment_content_type :media, :content_type => ['video/quicktime', 'video/mpeg', 'application/pdf']
  
  
  
   #acts as state machine plugin
  acts_as_state_machine :initial => :pending
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
    update_attribute(:media_file_name, "#{id}.flv")
  end
  

  
  
end

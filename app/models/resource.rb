class Resource < ActiveRecord::Base
  
  SUPPORTED_DOCUMENTS = ['application/pdf']
  
  # Plugins
  acts_as_commentable
  acts_as_taggable
  ajaxful_rateable :stars => 5
  validation_group :uploaded, :fields => [:title, :media]
  
  # Relationships
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :subjects
  has_and_belongs_to_many :exams
  
  
  belongs_to :owner, :class_name=> "User", :foreign_key => "owner_id"
  belongs_to :resourceable, :polymorphic => true
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  has_many :logs, :as => :logeable, :dependent => :destroy
  
  #has_one :clipping
  
  # Callbacks
  before_validation :enable_correct_validation_group
  #before_save :transform_resource
  
  # Validations
  validates_presence_of :name#, :external_resource_type, :external_resource
  #validates_inclusion_of :external_resource_type, :in => SUPPORTED_EXTERNAL_RESOURCES
  has_attached_file :media
  #validates_attachment_presence :media
  #validates_attachment_content_type :media,
  # :content_type => (SUPPORTED_DOCUMENTS)
  validates_attachment_size :media,
 	 :less_than => 10.megabytes
  
  named_scope :published, :conditions => ['published = ?', true], :include => :owner
  
  
  def name 
  	self.title
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
  
  ## transform the text and title into valid html
  def transform_resource
    # self.raw_post  = force_relative_urls(self.raw_post)
    self.url  = white_list(self.url)
    self.title = white_list(self.title)
  end
  
  def self.new_from_bookmarklet(params)
    self.new(
      :title => "#{params[:title] || params[:uri]}",
      :url => "<a href='#{params[:uri]}'>#{params[:uri]}</a>#{params[:selection] ? "<p>#{params[:selection]}</p>" : ''}"
    )
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
  
  #state machine 
  acts_as_state_machine :initial => :waiting
    state :waiting
    state :approved
    state :disapproved
    
    event :approve do
      transitions :from => :waiting, :to => :approved
   end
   
   event :disapprove do
      transitions :from => :waiting, :to => :disapproved
   end
   
  
  
end

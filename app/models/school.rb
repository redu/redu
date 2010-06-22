class School < ActiveRecord::Base
  
  acts_as_taggable
  
  before_create :create_root_folder
  
  
  #AVATAR
  has_attached_file :avatar, :styles => { :medium => "200x200>", :thumb => "100x100>" }
  
  #USERS
  has_many :user_school_association, :dependent => :destroy
  has_many :users, :through => :user_school_association, :conditions => ["user_school_associations.status LIKE 'approved'"]
  
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
   
  has_many :admins, :through => :user_school_association, :source => :user, :conditions => [ "user_school_associations.role_id = ?", 4 ]
  has_many :coordinators, :through => :user_school_association, :source => :user, :conditions => [ "user_school_associations.role_id = ?", 5 ]
  has_many :teachers, :through => :user_school_association, :source => :user, :conditions => [ "user_school_associations.role_id = ?", 6 ]
  has_many :students, :through => :user_school_association, :source => :user, :conditions => [ "user_school_associations.role_id = ?", 7 ]

  #FOLDERS
  has_many :folders
  
  
  has_many :forums
   
  has_many :acquisitions, :as => :acquired_by
  
  has_many :access_keys, :dependent => :destroy
  
  has_many :assets, :as => :asset, :class_name => 'SchoolAsset', :dependent => :destroy
  
  # VALIDATIONS
  validates_format_of       :path, :with => /^[\sA-Za-z0-9_-]+$/
  validates_presence_of :name, :path
  validates_uniqueness_of   :path, :case_sensitive => false
  validates_exclusion_of    :path, :in => AppConfig.reserved_logins
    
  
  # override activerecord's find to allow us to find by name or id transparently
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_path(args)
    else
      super
    end
  end
  
  
  def avatar_photo_url(size = nil)
    if self.avatar_file_name
      self.avatar.url(size)
    else
      case size
        when :thumb
          AppConfig.photo['missing_thumb']
        else
          AppConfig.photo['missing_medium']
      end
    end
  end
  
  #  def recent_school_activity
#    Log.find(:all, :conditions => ["school_id = ?", self.id], :order => "created_at DESC", :limit => 10)
#  end
  
  def recent_school_activity
    sql =  "SELECT l.id, l.logeable_type, l.action, l.user_id, l.logeable_name, l.logeable_id, l.created_at, l.updated_at, l.school_id FROM logs l, school_assets s WHERE 
    l.school_id = '#{self.id}' ORDER BY l.created_at DESC LIMIT 10 "
    @recent_school_activity = Log.find_by_sql(sql)
  end
  
#  def recent_school_exams_activity
#    Log.find(:all, :conditions => ["school_id = ? AND logeable_type = ?", self.id, "Exam" ], :order => "created_at DESC", :limit => 3)
#  end
  
  def recent_school_exams_activity
    sql =  "SELECT l.id, l.logeable_type, l.action, l.user_id, l.logeable_name, l.logeable_id, l.created_at, l.updated_at, l.school_id FROM logs l, school_assets s WHERE 
    l.school_id = '#{self.id}' AND l.logeable_type = '#{Exam}' ORDER BY l.created_at DESC LIMIT 3 "
    @recent_exams_activity = Log.find_by_sql(sql)
  end
  
#  def recent_school_courses_activity
#    Log.find(:all, :conditions => ["school_id = ? AND logeable_type = ?", self.id, "Course"], :order => "created_at DESC", :limit => 3)
#  end
  
  def recent_school_courses_activity
    sql =  "SELECT l.id, l.logeable_type, l.action, l.user_id, l.logeable_name, l.logeable_id, l.created_at, l.updated_at, l.school_id FROM logs l, school_assets s WHERE 
    l.school_id = '#{self.id}' AND l.logeable_type = '#{Course}' ORDER BY l.created_at DESC LIMIT 3 "
    @recent_courses_activity = Log.find_by_sql(sql)
  end
  

 def spotlight_courses
   sql =  "SELECT c.name FROM courses c, school_assets s WHERE 
    s.school_id = '#{self.id}' AND s.asset_type = '#{Course}' AND c.id = s.asset_id ORDER BY c.view_count DESC LIMIT 6 "
   @spotlight_courses = Course.find_by_sql(sql)
  end

  
  
  def create_root_folder
    @folder = Folder.create(:name => "root")
    self.folders << @folder
  end
  
  def root_folder
    Folder.find(:first, :conditions => ["school_id = ? AND parent_id IS NULL", self.id])
  end
  
end

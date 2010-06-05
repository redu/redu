class School < ActiveRecord::Base
  
   acts_as_taggable
   
   
   # ajaxful_rateable :stars => 5#, :dimensions => [:speed, :beauty, :price]
    has_attached_file :avatar, :styles => { :medium => "200x200>", :thumb => "100x100>" }
    
    has_many :user_school_association, :dependent => :destroy
    has_many :users, :through => :user_school_association, :conditions => ["user_school_associations.status LIKE 'approved'"]
    
    belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
    
    has_many :forums
    
    has_many :admins, :through => :user_school_association, :source => :user, :conditions => [ "user_school_associations.role_id = ?", 4 ]
    has_many :coordinators, :through => :user_school_association, :source => :user, :conditions => [ "user_school_associations.role_id = ?", 5 ]
    has_many :teachers, :through => :user_school_association, :source => :user, :conditions => [ "user_school_associations.role_id = ?", 6 ]
    has_many :students, :through => :user_school_association, :source => :user, :conditions => [ "user_school_associations.role_id = ?", 7 ]

    has_many :acquisitions, :as => :acquired_by

    has_many :access_keys, :dependent => :destroy
    
    has_many :assets, :as => :asset, :class_name => 'SchoolAsset', :dependent => :destroy
    
    validates_format_of       :path, :with => /^[\sA-Za-z0-9_-]+$/
    validates_presence_of :name, :path
    validates_uniqueness_of   :path, :case_sensitive => false
    validates_exclusion_of    :path, :in => AppConfig.reserved_logins
    
#    def can_be_managed_by(user)
#      #TODO verificar se é professor ou coord, ou school admin tbm
#      (self.owner == user || user.)
#  end
  
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
  
  def recent_school_activity
    Log.find(:all, :conditions => ["school_id = ?", self.id], :order => "created_at DESC", :limit => 10)
  end
  
  def recent_school_exams_activity
    Log.find(:all, :conditions => ["school_id = ? AND logeable_type = ?", self.id, "Exam" ], :order => "created_at DESC", :limit => 3)
  end
  
  def recent_school_courses_activity
    Log.find(:all, :conditions => ["school_id = ? AND logeable_type = ?", self.id, "Course"], :order => "created_at DESC", :limit => 3)
  end
  
  
end

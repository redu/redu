class School < ActiveRecord::Base
  
   acts_as_taggable
   # ajaxful_rateable :stars => 5#, :dimensions => [:speed, :beauty, :price]
    has_attached_file :avatar, :styles => { :medium => "200x200>", :thumb => "100x100>" }
    
    has_many :user_school_association, :dependent => :destroy
    has_many :users, :through => :user_school_association
    
    belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
    
    has_many :forums
    
    has_many :coordinators, :through => :user_school_association, :source => :user, :conditions => [ "user_school_associations.role_id = ?", 5 ]
    has_many :teachers, :through => :user_school_association, :source => :user, :conditions => [ "user_school_associations.role_id = ?", 6 ]
    has_many :students, :through => :user_school_association, :source => :user, :conditions => [ "user_school_associations.role_id = ?", 7 ]

    has_many :acquisitions, :as => :acquired_by

    has_many :access_keys, :dependent => :destroy
    
    has_many :assets, :as => :asset, :class_name => 'SchoolAssets'
    
    validates_presence_of :name
    
    def can_be_managed_by(user)
      #TODO verificar se é professor ou coord, ou school admin tbm
      (self.owner == user)
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
    
  
end

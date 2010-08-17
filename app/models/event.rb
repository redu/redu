class Event < ActiveRecord::Base
  #acts_as_activity :user
  validates_presence_of :name, :identifier => 'validates_presence_of_name'
  validates_presence_of :start_time
  validates_presence_of :end_time
  validates_presence_of :owner

  belongs_to :owner, :class_name => "User", :foreign_key => 'owner'
  belongs_to :metro_area
  #has_many :rsvps, :dependent=>:destroy
  #has_many :attendees, :source=>:user, :through=>:rsvps

  #attr_protected :owner
  
  #Procs used to make sure time is calculated at runtime
  named_scope :upcoming, lambda { { :order => 'start_time', :conditions => ['end_time > ?' , Time.now ] } }
  named_scope :past, lambda { { :order => 'start_time DESC', :conditions => ['end_time <= ?' , Time.now ] } }  
  
  
  acts_as_commentable

  # Used by acts_as_commentable
#  def owner
#    self.owner
#  end    
  
  #def rsvped?(user)
    #self.rsvps.find_by_user_id(user)
  #end

  #def attendees_for_user(user)
    #self.rsvps.find_by_user_id(user).attendees_count
  #end

  #def attendees_count
    #self.rsvps.sum(:attendees_count)
  #end

  def time_and_date
    if end_time < Time.now
      string = "Ocorreu"
    else
      string = "Ocorrerá"
    end
          
    if spans_days?
      string += " de #{start_time.strftime("%d/%m")} à #{end_time.strftime("%d/%m/%Y")}"
    else
      string += " dia #{start_time.strftime("%d/%m/%Y")}, #{start_time.strftime("%I:%M %p")} - #{end_time.strftime("%I:%M %p")}"
    end
  end

  def spans_days?
    (end_time - start_time) >= 86400
  end
  
  protected
  def validate
    errors.add("start_time", " must be before end time") unless start_time && end_time && (start_time < end_time)
  end  
  
end

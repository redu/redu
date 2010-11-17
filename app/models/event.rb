class Event < ActiveRecord::Base

  # ASSOCIATIONS
  has_many :logs, :as => :logeable, :dependent => :destroy, :class_name => 'Status'
  belongs_to :owner, :class_name => "User", :foreign_key => 'owner'
  belongs_to :space

  # NAMED SCOPES
  #Procs used to make sure time is calculated at runtime
  named_scope :upcoming, lambda { { :order => 'start_time', :conditions => ['end_time > ?' , Time.now ] } }
  named_scope :past, lambda { { :order => 'start_time DESC', :conditions => ['end_time <= ?' , Time.now ] } }
  named_scope :approved, :conditions => { :state => 'approved' }


  # PLUGINS
  acts_as_taggable
  acts_as_voteable
  #acts_as_activity :user
  acts_as_state_machine :initial => :waiting

  state :waiting
  state :approved
  state :rejected
  state :error

  event :approve do
    transitions :from => :waiting, :to => :approved
  end

  event :reject do
    transitions :from => :waiting, :to => :rejected
  end

  # VALIDATIONS
  validates_presence_of :name, :identifier => 'validates_presence_of_name'
  validates_presence_of :start_time
  validates_presence_of :end_time
  validates_presence_of :owner
  validates_presence_of :tagline
  validates_length_of :tagline, :maximum => AppConfig.desc_char_limit

  def time_and_date
    if end_time < Time.now
      string = "Ocorreu"
    else
      string = "Ocorrerá"
    end

    if spans_days?
      if start_time.hour == 0
        string += " de #{start_time.strftime("%d/%m")} à "
      else
        string += " de #{start_time.strftime("%d/%m %I:%M %p")} à "
      end

      if end_time.hour == 0
        string += "#{end_time.strftime("%d/%m/%Y")}"
      else
        string += "#{end_time.strftime("%d/%m/%Y %I:%M %p")}"
      end
    else
      string += " dia #{start_time.strftime("%d/%m/%Y")}, #{start_time.strftime("%I:%M %p")} - #{end_time.strftime("%I:%M %p")}"
    end
  end

  def spans_days?
    (end_time - start_time) >= 86400
  end

  protected
  def validate
    errors.add("Início", " deve ser antes do término.") unless start_time && end_time && (start_time < end_time)
  end
end

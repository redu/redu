class Event < ActiveRecord::Base

  # ASSOCIATIONS
  has_many :logs, :as => :logeable, :dependent => :destroy, :class_name => 'Status'
  belongs_to :owner, :class_name => "User", :foreign_key => 'owner'
  belongs_to :eventable, :polymorphic => true

  # SCOPES
  #Procs used to make sure time is calculated at runtime
  scope :upcoming, lambda { order('start_time').where('end_time > ?',
                                                      Time.now) }
  scope :past, lambda { order('start_time DESC').where('end_time <= ?',
                                                       Time.now) }
  scope :approved, where(:state => 'approved')
  scope :waiting, where(:state => 'waiting')

  # PLUGINS
  acts_as_taggable
  #acts_as_activity :user

  # Máquina de estados para moderação de Eventos
  aasm_column :state

  aasm_initial_state :waiting

  aasm_state :waiting
  aasm_state :approved
  aasm_state :rejected
  aasm_state :error #FIXME estado sem transicões, é assim mesmo?

  aasm_event :approve do
    transitions :to => :approved, :from => [:waiting]
  end

  aasm_event :reject do
    transitions :to => :rejected, :from => [:waiting]
  end

  # VALIDATIONS
  validates_presence_of :name, :identifier => 'validates_presence_of_name'
  validates_presence_of :description, :start_time, :end_time, :owner
  validates_length_of :name, :maximum => 60
  validates_length_of :description, :maximum => 5000

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

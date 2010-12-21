class Invitation < ActiveRecord::Base

  belongs_to :user
  belongs_to :inviteable, :polymorphic => true
  has_enumerated :role

  validates_presence_of :user
  validates_presence_of :email_addresses
  validates_length_of :email_addresses, :minimum => 6
  validates_length_of :email_addresses, :maximum => 1500

  validates_each :email_addresses do |record, attr, email_addresses |
    invalid_emails = []
    email_addresses = email_addresses || ''
    emails = email_addresses.split(",").collect{|email| email.strip }.uniq

    emails.each{ |email|
      unless email =~ /[\w._%-]+@[\w.-]+.[a-zA-Z]{2,4}/
        invalid_emails << email
      end
    }

    unless invalid_emails.empty?
      record.errors.add(:email_addresses, " included invalid addresses: <ul>"+invalid_emails.collect{|email| '<li>'+email+'</li>' }.join+"</ul>")
      record.email_addresses = (emails - invalid_emails).join(', ')
    end
  end

  # Estados de um invitation
  acts_as_state_machine :initial => :pending, :column => :state

  state :pending
  state :invited, :enter => :send_invite
  state :added
  state :failed

  event :invite do
    transitions :from => :pending, :to => :invited
    transitions :from => :invited, :to => :invited
  end

  event :add do
    transitions :from => :invited, :to => :added
  end

  event :fail do
    transitions :from => :invited, :to => :failed
    transitions :from => :added, :to => :failed
  end

  def send_invite
    emails = self.email_addresses.split(",").collect{|email| email.strip }.uniq
    emails.each{|email|
      UserNotifier.deliver_environment_invitation(self.user,
                                                  email,
                                                  self.role,
                                                  self.inviteable,
                                                  self.message)
    }
  end

end

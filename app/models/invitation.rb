class Invitation < ActiveRecord::Base

  validates_presence_of :email, :hostable, :user
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9A-Z]+\.)+[a-zA-Z]{2,})$/
  validates_uniqueness_of :email, :scope => [:hostable_id, :hostable_type]

  validate :validate_invitee, :on => :create

  before_validation :generate_token, :on => :create

  belongs_to :hostable, :polymorphic => true
  belongs_to :user

  def self.invite(params, &block)
    invitation = Invitation.create(params)
    if invitation.valid?
      block.call(invitation) if block_given?
      invitation
    else
      invitation.errors
    end
  end

  def send_email(&block)
    block.call(self) if block_given?
  end
  alias :resend_email :send_email

  # hostable => entidate ao qual o convidado (invitee) será associado
  def accept!(invitee)
    self.hostable.process_invitation!(invitee, self)
  end

  protected
  def validate_invitee
   errors.add(:invitee,"Não pode convidar a si próprio") if (self.email and self.user.email == self.email)
  end

  def generate_token
    self.token = rand(36**11).to_s(36)
    self.generate_token unless Invitation.where(:token => self.token).empty?
  end
end

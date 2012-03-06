class Invitation < ActiveRecord::Base

  validates_presence_of :email, :hostable
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9A-Z]+\.)+[a-zA-Z]{2,})$/
  before_validation :generate_token, :on => :create

  belongs_to :hostable, :polymorphic => true
  belongs_to :user

  # hostable => entidate ao qual o convidado (invitee) será associado
  def accept!(invitee)
    @hostable.process_invitation!(invitee, self)
  end

  protected
  def generate_token
    self.token = ActiveSupport::SecureRandom.base64(8).gsub("/","_").
      gsub(/=+$/,"")
  end
end

# Open some classes
class User < ActiveRecord::Base

  has_many :invitations, :dependent => :destroy

  def process_invitation!(invitee, invitation)
    if self.be_friends_with(invitee)[0]
       invitation.delete
    else
      false
    end
  end
end

class UserCourseInvitation < CourseEnrollment

  #FIXME: validar accept state machine
  def process_invitation!(invitee, invitation)
    begin
      self.accept!
      invitation.delete
    rescue
      false
    end
  end
end


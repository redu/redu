class UserCourseInvitation < ActiveRecord::Base
  require 'active_support'

  belongs_to :user
  belongs_to :course

  before_validation_on_create :generate_token

  named_scope :invited, :conditions => { :state => 'invited' }
  named_scope :with_email, lambda { |email|
    { :conditions => { :email => email } }
  }

  acts_as_state_machine :initial => :invited
  # Envia e-mail avisando que ele foi convidado
  state :invited, :enter => :send_external_user_course_invitation
  # Convida o usuário (já dentro do Redu) para o curso
  state :approved, :enter => :create_user_course_association
  state :rejected
  state :failed

  # Necessita que um usuário seja setado ANTES de chamar este método;
  # caso contrário, falha silenciosamente
  event :accept do
    transitions :from => :invited, :to => :approved,
      :guard => Proc.new { |i| i.user }
  end

  event :deny do
    transitions :from => :invited, :to => :rejected
  end

  event :fail do
    transitions :from => :invited, :to => :failed
  end

  validates_presence_of :token, :email, :course
  validates_uniqueness_of :token
  validates_uniqueness_of :email, :scope => :course_id
  validates_format_of :email,
    :with => /^([^@\s]+)@((?:[-a-z0-9A-Z]+\.)+[a-zA-Z]{2,})$/

  def send_external_user_course_invitation
    UserNotifier.external_user_course_invitation(self, self.course).deliver
  end

  protected

  def generate_token
    self.token = ActiveSupport::SecureRandom.base64(8).gsub("/","_").
      gsub(/=+$/,"")
  end

  def create_user_course_association
    self.course.invite(self.user)
  end
end

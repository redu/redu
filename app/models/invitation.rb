class Invitation < ActiveRecord::Base

  validates_presence_of :email, :invitable

  belongs_to :user

  protected
  def generate_token
    self.token = ActiveSupport::SecureRandom.base64(8).gsub("/","_").
      gsub(/=+$/,"")
  end

end

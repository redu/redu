# -*- encoding : utf-8 -*-
class AccessToken < OauthToken
  validates_presence_of :user, :secret
  before_create :set_authorized_at

  # Implement this to return a hash or array of the capabilities the access token has
  # This is particularly useful if you have implemented user defined permissions.
  # def capabilities
  #   {:invalidate=>"/oauth/invalidate",:capabilities=>"/oauth/capabilities"}
  # end

  scope :valid, where("invalidated_at IS NULL AND authorized_at IS NOT NULL")

  def self.user_token_for(user, application)
    where(:user_id => user).valid.first(:conditions => {
      :client_application_id => application })
  end

  protected

  def set_authorized_at
    self.authorized_at = Time.now
  end
end

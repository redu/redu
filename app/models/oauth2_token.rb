# -*- encoding : utf-8 -*-
class Oauth2Token < AccessToken
  scope :valid, where("invalidated_at IS NULL AND authorized_at IS NOT NULL")

  attr_accessor :state
  def as_json(options={})
    d = {:access_token=>token, :token_type => 'bearer'}
    d[:expires_in] = expires_in if expires_at
    d
  end

  def to_query
    q = "access_token=#{token}&token_type=bearer"
    q << "&state=#{URI.escape(state)}" if @state
    q << "&expires_in=#{expires_in}" if expires_at
    q << "&scope=#{URI.escape(scope)}" if scope
    q
  end

  def expires_in
    expires_at.to_i - Time.now.to_i
  end

  def self.verify_token(token)
    self.find_by_token_and_invalidated_at(token, nil)
  end
end

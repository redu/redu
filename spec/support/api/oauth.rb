# -*- encoding : utf-8 -*-
module OAuth
  module Helpers
    def generate_token(user=nil, application=nil)
      application ||= FactoryGirl.create(:client_application)
      user ||= FactoryGirl.create(:user)
      token = ::Oauth2Token.create(:client_application => application,
                                   :user => user).token

      [application, user, token]
    end
  end
end

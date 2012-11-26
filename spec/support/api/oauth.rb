module OAuth
  module Helpers
    def generate_token(user=nil, application=nil)
      application ||= Factory(:client_application)
      user ||= Factory(:user)
      token = ::Oauth2Token.create(:client_application => application,
                                   :user => user).token

      [application, user, token]
    end
  end
end

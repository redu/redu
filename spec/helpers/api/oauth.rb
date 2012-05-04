module OAuth
  module Helpers
    def generate_token(user=nil)
      application = Factory(:client_application)
      user ||= Factory(:user)
      token = ::AccessToken.create(:client_application => application,
                                   :user => user).token

      [application, user, token]
    end
  end
end

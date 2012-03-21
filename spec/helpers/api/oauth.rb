module OAuth
  module Helpers
    def generate_token
      application = Factory(:client_application)
      current_user = Factory(:user)
      token = ::AccessToken.create(:client_application => application,
                                 :user => current_user).token

      [application, current_user, token]
    end
  end
end

module Api
  module Helpers
    def parse(json)
      ActiveSupport::JSON.decode(json)
    end

    def href_to(rel, representation)
      link = representation.fetch('links', []).
        detect { |link| link['rel'] == rel }

      link ? link['href'] : ''
    end
  end
end

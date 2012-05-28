require 'spec_helper'

describe AccessToken do
  it "should return token from user" do
    user = Factory(:user)
    application = Factory(:client_application, :user => user)
    access = AccessToken.create(:user => user,
                                :client_application => application)
    token = access.token

    AccessToken.user_token_for(user, application).token.should \
      == token
  end
end

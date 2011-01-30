require 'spec_helper'
require 'authlogic/test_case'

describe UsersController do
  
  before do
    users = (1..4).collect { Factory(:user) }
    users[0].be_friends_with(users[1])
    users[0].be_friends_with(users[2])
    users[0].be_friends_with(users[3])
    users[1].be_friends_with(users[0])
    users[2].be_friends_with(users[0])
    @friends = [users[1], users[2]]
    @user = users[0]
    activate_authlogic
    UserSession.create @user
  end

  
end

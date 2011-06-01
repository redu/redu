require 'spec_helper'

describe PresenceController do
  before do
    @current_user = Factory(:user)
    @friend1 = Factory(:user)
    @friend2 = Factory(:user)
    @friend3 = Factory(:user)
    @user2 = Factory(:user)
    @user3 = Factory(:user)

    # primeiro curso
    environment = Factory(:environment)
    course = Factory(:course, :owner => environment.owner,
                     :environment => environment)
    space = Factory(:space, :owner => environment.owner,
                     :course => course)

    # segundo curso
    course2 = Factory(:course, :environment => environment,
                      :owner => environment.owner)
    course3 = Factory(:course)

    course.join(@current_user)
    course2.join(@current_user)

    course.join(@friend1, Role[:teacher])
    course2.join(@friend1, Role[:tutor])

    course.join(@friend2)
    course3.join(@user2)

    @current_user.be_friends_with(@friend1)
    @friend1.be_friends_with(@current_user)
    @current_user.be_friends_with(@friend2)
    @friend2.be_friends_with(@current_user)
    @current_user.be_friends_with(@friend3)
    @friend3.be_friends_with(@current_user)
  end

  context "POST 'auth'" do

    it "return a list of friends and user_id" do

    end

    it "return name, thumbail and channel of current_user" do

    end

  end
end

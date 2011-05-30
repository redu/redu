require 'spec_helper'

describe Presence do

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

  xit "should retrieve a hash with all properties" do
    Presence.list_of_friends(@current_user).to_set.
      should == [ {:channel => "presence-user-#{@friend1.id}",
                   :roles => { "teacher" => true,
                               "member" => false,
                               "admin" => false,
                               "environment_admin" => false,
                               "tutor" => true,
                               "course_admin" => false},
                   :name => @friend1.display_name},
                  {:channel => "presence-user-#{@friend2.id}",
                   :roles => { "teacher" => false,
                               "member" => true,
                               "admin" => false,
                               "environment_admin" => false,
                               "tutor" => false,
                               "course_admin" => false},
                   :name => @friend2.display_name},
                  {:channel => "presence-user-#{@friend3.id}",
                   :roles => { "teacher" => false,
                               "member" => false,
                               "admin" => false,
                               "environment_admin" => false,
                               "tutor" => false,
                               "course_admin" => false},
                   :name => @friend3.display_name}].to_set
  end

  it "should retrieve a hash of channels of friends" do
    Presence.list_of_channels(@current_user).to_set.
      should == [ {:channel => "presence-user-#{@friend1.id}" },
        {:channel => "presence-user-#{@friend2.id}" },
        {:channel => "presence-user-#{@friend3.id}" }].to_set
  end

  it "should retrieve the right roles" do
   Presence.fill_roles(@friend1).should == { "teacher" => true,
                                          "member" => false,
                                          "admin" => false,
                                          "environment_admin" => false,
                                          "tutor" => true,
                                          "course_admin" => false }
  end
end

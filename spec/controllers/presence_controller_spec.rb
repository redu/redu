require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe PresenceController do
  render_views

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
    activate_authlogic
    UserSession.create @current_user
  end

  context "POST 'auth'" do

    context "authenticating" do

      context "presence channel" do

        before do
          post :auth, :locale => "pt-BR",
            :channel_name => "presence-user-#{@current_user.id}",
          :socket_id => "539.9111", :user_id => @current_user.id
        end

        it "should be successful" do
          response.should be_success
        end

        it "should return a list of contacts and user_id" do
          payload = {:user_id => @current_user.id,
            :user_info => {
            :contacts => Presence.list_of_channels(@current_user)} }

          user_info = JSON.parse(response.body)
          user_info["channel_data"].should == payload.to_json
        end

      end

      context "private channel" do
        before do
          post :auth, :locale => "pt-BR",
            :channel_name => "private-#{@current_user.id}-#{@friend1.id}",
            :socket_id => "123.13865", :user_id => @current_user.id
        end

        it "should be successful" do
          response.should be_success
        end

        it "should retrive an auth key" do
          json_response = JSON.parse(response.body)
          json_response.should have_key("auth")
        end
      end

      context "subscribe to a contact's channel" do

        before do
          post :auth, :locale => "pt-BR",
            :channel_name => "presence-user-#{@friend1.id}",
            :socket_id => "213.2312", :user_id => @current_user.id
        end

        it "should be successful" do
          response.should be_success
        end

        it "return name, thumbnail and channel of current_user" do
          payload = { :user_id => @current_user.id,
            :user_info => { :name => @current_user.display_name,
            :thumbnail => @current_user.avatar.url(:thumb_24),
            :channel => @current_user.presence_channel,
            :roles => Presence.fill_roles(@current_user) }}
          user_info = JSON.parse(response.body)
          user_info["channel_data"].should == payload.to_json
        end

      end
    end

    context "subscribe a strange channel" do

      context "presence" do
        before do
          post :auth, :locale => "pt-BR",
            :channel_name => "presence-user-#{@user2.id}",
            :socket_id => "212.2113", :user_id => @current_user.id
        end

        it "should not be success" do
          response.should_not be_success
        end

      end

    end

  end
end

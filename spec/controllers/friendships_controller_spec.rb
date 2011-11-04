require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe FriendshipsController do

  before do
    User.maintain_sessions = false
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

  describe "GET 'index'" do
    before do
      get :index, :locale => "pt-BR", :user_id => @user.login
    end
    it "should load all friends" do
      assigns[:friends].should == @friends
    end
  end

  describe "POST 'create'" do
    before do
      @new_user = Factory(:user)
    end

    it "creates a friendship, returning HTML" do
      lambda {
        post :create, :locale => "pt-BR", :user_id => @user.login,
        :friend_id => @new_user.id
      }.should change(Friendship, :count).by(2)
    end

    it "creates a friendship, returning JS" do
      lambda {
        post :create, :locale => "pt-BR", :user_id => @user.login,
        :friend_id => @new_user.id, :goto_home => true, :format => :js
      }.should change(Friendship, :count).by(2)
    end

    it "redirects to user profile, unsing HTML " do
      post :create, :locale => "pt-BR", :user_id => @user.login,
        :friend_id => @new_user.id
      response.should redirect_to(user_path(@new_user))
    end

    it "redirects to user profile, unsing HTML with goto_home" do
      post :create, :locale => "pt-BR", :user_id => @user.login,
        :friend_id => @new_user.id, :goto_home => true
      response.should redirect_to(home_user_path(@user))
    end

  end

  describe "POST 'destroy'" do
    before do
      @new_user = Factory(:user)
      @user.be_friends_with(@new_user)
      @new_user.be_friends_with(@user)
      @friendship = @user.friendship_for @new_user
    end

    it "destroy a friendship, returning JS" do
      lambda {
        post :destroy, :locale => "pt-BR", :user_id => @user.login,
          :id => @friendship.id, :format => :js
      }.should change(Friendship, :count).by(-2)
    end

    it "destroy a friendship, returning HTML" do
      lambda {
        post :destroy, :locale => "pt-BR", :user_id => @user.login,
          :id => @friendship.id
      }.should change(Friendship, :count).by(-2)
    end

    it "redirects to user profile returning HTML" do
      post :destroy, :locale => "pt-BR", :user_id => @user.login,
        :id => @friendship.id
      response.should redirect_to(user_path(@new_user))
    end

    it "redirects to user profile, returning HTML with goto_home" do
      post :destroy, :locale => "pt-BR", :user_id => @user.login,
        :id => @friendship.id, :goto_home => true
      response.should redirect_to(home_user_path(@user))
    end

  end

end

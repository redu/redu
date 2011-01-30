require 'spec_helper'
require 'authlogic/test_case'

describe FriendshipsController do
  
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

  describe "GET 'index'" do
    before do
      get :index, :locale => "pt-BR", :user_id => @user.id
    end
    it "should load all friends" do
      assigns[:friends].should == @friends
    end
  end
  
  describe "GET 'pending'" do
    before do
      @new_user = Factory(:user)
      @user.be_friends_with(@new_user)
    end
    it "should load all pending friends" do
      get :pending, :locale => "pt-BR", :user_id => @new_user.id
      assigns[:friends_pending].should == [@user]
    end
  end
 
  describe "POST 'create'" do
    before do
      @new_user = Factory(:user)
    end

    it "creates a friendship" do
      lambda {
        post :create, :locale => "pt-BR", :user_id => @user.id
      }.should change(Friendship, :count).by(2)
    end

    it "redirects to user profile" do
      post :create, :locale => "pt-BR", :user_id => @user.id
      response.should redirect_to(user_path(@user))
    end
  end
  
  describe "POST 'destroy'" do
    before do
      @new_user = Factory(:user)
      @user.be_friends_with(@new_user)
      @new_user.be_friends_with(@user)
    end

    it "destroy a friendship" do
      lambda {
        post :destroy, :locale => "pt-BR", :user_id => @user.id, :id => @new_user.id
      }.should change(Friendship, :count).by(-2)
    end

    it "redirects to user profile" do
      post :destroy, :locale => "pt-BR", :user_id => @user.id, :id => @new_user.id
      response.should redirect_to(user_path(@user))
    end
  end

  describe "POST 'accept'"  do
    before do
      @new_user = Factory(:user)
      @user.be_friends_with(@new_user)
      @friendship = @new_user.friendship_for(@user)
    end

    it "accepts a friendship" do
      expect {
        post :accept, :locale => "pt-BR", :user_id => @new_user.id, :id => @user.id 
      }.should change(@user.friends, :count).by(1)
    end

    it "redirects to user notifications" do
      post :accept, :locale => "pt-BR", :user_id => @new_user.id, :id => @user.id
      response.should redirect_to(pending_user_friendships_path(@new_user))
    end
  end

  describe "POST 'decline'" do
    before do
      @new_user = Factory(:user)
      @user.be_friends_with(@new_user)
      @friendship = @new_user.friendship_for(@user)
    end
    it "decline and destroy a friendship" do
      expect {
        post :decline, :locale => "pt-BR", :user_id => @new_user.id, :id => @user.id
      }.should change(Friendship, :count).by(-2)
    end
    it "redirects to user notifications" do
       post :decline, :locale => "pt-BR", :user_id => @new_user.id, :id => @user.id
       response.should redirect_to(pending_user_friendships_path(@new_user))
    end
  end

  
end

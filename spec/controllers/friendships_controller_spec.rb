require 'spec_helper'
require 'authlogic/test_case'

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
    login_as @user
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
      expect {
        post :create, :locale => "pt-BR", :user_id => @user.login,
        :friend_id => @new_user.id
      }.to change(Friendship, :count).by(2)
    end

    it "creates a friendship, returning JS" do
      expect {
        post :create, :locale => "pt-BR", :user_id => @user.login,
        :friend_id => @new_user.id, :goto_home => true, :format => :js
      }.to change(Friendship, :count).by(2)
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
      expect {
        post :destroy, :locale => "pt-BR", :user_id => @user.login,
        :id => @friendship.id, :format => :js
      }.to change(Friendship, :count).by(-2)
    end

    it "destroy a friendship, returning HTML" do
      expect {
        post :destroy, :locale => "pt-BR", :user_id => @user.login,
        :id => @friendship.id
      }.to change(Friendship, :count).by(-2)
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

  context 'new action' do
    before do
      @friend = @friends[0]
    end
    context 'when user logged' do
      before do
        controller.process_invites({'emails' => 'example.mail.com, teste@mail.com', 'friend_id' => @friend.id}, @user)
        @params = {:locale => "pt-BR", :user_id => @user.login}
        login_as @user
        get :new, @params
      end

      it 'assigns all invitations from current user' do
        assigns(:invitations).should == @user.invitations
      end

      it 'assigns all friendship requests with requested current state' do
        assigns(:friendship_requests).should == @user.friendships.requested
      end

      it 'render new template' do
        response.should render_template('new')
      end
    end
  end


  context 'When resend invitation email' do
    let(:friend) { @friends[0] }
    let(:friendship_request) { @user.friendship_for(friend) }
    before do
      controller.process_invites({'emails' => 'example1@email.com',
                                  'friend_id' => friend.id }, @user)
      @params = { :locale => "pt-BR", :id => friendship_request.id,
                  :user_id => @user.login }
      xhr :post, :resend_email, @params
    end

    it 'assigns invitation_id' do
      assigns(:invitation_id).should == "friendship-request-for-#{friend.id}"
    end

    it 'render js template' do
      response.should render_template('invitations/resend_email')
    end
  end
end

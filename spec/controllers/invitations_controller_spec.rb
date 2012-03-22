require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe InvitationsController do
  before do
    User.maintain_sessions = false
    activate_authlogic
    @user = Factory(:user)
    @friend = Factory(:user)
    InvitationsUtil.process_invites({'emails' => 'example@email.com', 'friend_id' => @friend.id}, @user)
    @invitation = @user.invitations.last
    @params = {:locale => "pt-BR", :id => @invitation.id}
  end

  context "Show action" do
    before do
      UserSession.create(@friend)
      get :show, @params
    end
    it 'Invitation must be accepted' do
      @friend.friendships.count.should == 1
      @user.friendships.count.should == 1
      Invitation.all.count.should == 0
    end

    it 'Redirect to user_home_path' do
      response.should redirect_to(home_user_path(@friend))
    end

    context 'Invitation already accepted' do
      before do
        @invitation.accept!(@friend)
        get :show, @params
      end

      it do
        lambda{Invitation.find(@invitation)}.should raise_error
        @user.invitations.should be_empty
        @user.friendships.count.should == 1
        @friend.friendships.count.should == 1
      end

      it 'Redirect to home_path' do
        response.should redirect_to(home_path)
      end
    end

    context 'Invitation already deleted' do
      before do
        @invitation.destroy
        get :show, @params
      end

      it do
        lambda{Invitation.find(@invitation)}.should raise_error
        @user.invitations.should be_empty
        @user.friendships.requested.count.should == 1
      end

      it 'Redirect to home_path' do
        response.should redirect_to(home_path)
      end
    end
  end

  context 'User not loggued:' do
    before do
      @guest = Factory(:user)
      InvitationsUtil.process_invites({'emails' => 'example@email.com'}, @guest)
      @invitation = @guest.invitations.last
      @params = {:locale => "pt-BR", :id => @invitation.id}
      get :show, @params
    end

    it 'redirect to invitation_path' do
      response.should be_success
      response.should render_template("show")
    end

    it 'assigns user' do
      assigns(:user).should == @invitation.user
    end

    it 'assigns contacts' do
      assigns(:contacts)[:total].should == @guest.friends.count
    end

    it 'assigns courses' do
      uca = UserCourseAssociation.where(:user_id => @guest).approved
      @courses = { :total => @guest.friends.count,
                   :environment_admin => uca.with_roles([:environment_admin]).count,
                   :tutor => uca.with_roles([:tutor]).count,
                   :teacher => uca.with_roles([:teacher]).count }
      assigns(:courses)[:total].should == @courses[:total]
      assigns(:courses)[:environment_admin].should == @courses[:environment_admin]
      assigns(:courses)[:tutor].should == @courses[:tutor]
      assigns(:courses)[:teacher].should == @courses[:teacher]
    end
  end
  context 'Resend email' do
    before do
      @params.store(:format, 'js')
      post :resend_email, @params
    end

    it 'assigns invitation_id' do
      assigns(:invitation_id).should == "invitation-#{@invitation.id}"
    end

    it 'render js template' do
      response.should render_template('invitations/resend_email')
    end
  end
end

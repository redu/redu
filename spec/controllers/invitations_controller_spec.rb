require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe InvitationsController do
  before do
    User.maintain_sessions = false
    activate_authlogic
  end

  context "Show action" do
    before do
      @user = Factory(:user)
      @friend = Factory(:user)
    end

    context 'Invitation already accepted' do
      before do
        InvitationsUtil.process_invites({'emails' => 'example@email.com'}, @user)
        @invitation = @user.invitations.last
        @params = {:locale => "pt-BR", :id => @invitation.id}
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

    context 'Invitaiton already deleted' do
      before do
        InvitationsUtil.process_invites({'emails' => 'example@email.com'}, @user)
        @invitation = @user.invitations.last
        @params = {:locale => "pt-BR", :id => @invitation.id}
        @invitation.destroy
        get :show, @params
      end

      it do
        lambda{Invitation.find(@invitation)}.should raise_error
        @user.invitations.should be_empty
        @user.friendships.count.should == 0
      end

      it 'Redirect to home_path' do
        response.should redirect_to(home_path)
      end
    end

    context 'User logged' do
      before do
        UserSession.create(@friend)
        InvitationsUtil.process_invites({'emails' => 'example@email.com'}, @user)
        @invitation = @user.invitations.last
        @params = {:locale => "pt-BR", :id => @invitation.id}
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
    end

    context 'User not loggued:' do
      before do
        InvitationsUtil.process_invites({'emails' => 'example@email.com'}, @user)
        @invitation = @user.invitations.last
        @params = {:locale => "pt-BR", :id => @invitation.id}
        get :show, @params
      end

      it 'redirect to invitation_path' do
        response.should be_success
      end
    end
  end
end

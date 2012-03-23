require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe InvitationsController do
  before do
    User.maintain_sessions = false
    activate_authlogic
    @user = Factory(:user)
    @friend = Factory(:user)
    @invitation_params = {}
    @invitation_params.store('emails', 'example@email.com')
    @invitation_params.store('friend_id', @friend.id)
    InvitationsUtil.process_invites(@invitation_params, @user)

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
      @user = Factory(:user)
      InvitationsUtil.process_invites(@invitation_params, @user)
      @invitation = @user.invitations.last
      @params = {:locale => "pt-BR", :id => @invitation.id}
      get :show, @params
    end

    it 'redirect to invitation_path' do
      response.should be_success
      response.should render_template("show")
    end

    it 'assigns user' do
      assigns(:invitation_user).should == @invitation.user
    end

    it 'assigns contacts' do
      assigns(:contacts)[:total].should == @user.friends.count
    end

    it 'assigns courses' do
      uca = UserCourseAssociation.where(:user_id => @user).approved
      @courses = { :total => @user.courses.count,
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

  context 'Destroy action' do
    before do
      UserSession.create(@user)
      @params.store(:id, @invitation.id)
      delete :destroy, @params
    end

    it 'Invitations should be deleted' do
      Invitation.all.should be_empty
      InvitationsUtil.process_invites(@invitation_params, @user)
      @params.store(:id, Invitation.last.id)
      expect {
        delete :destroy, @params
      }.should change {Invitation.all.count}.from(1).to(0)
    end

    it 'sucess messagem should be presented' do
      flash[:notice].should_not be_nil
      flash[:notice].should == "O convite foi removido com sucesso."
    end

    it 'Should be redirected to user home' do
      response.should redirect_to(home_user_path(@user))
    end

    context 'Invitations has already been destroyed' do
      before do
        @params.store(:id, @invitation.id)
        @invitation.destroy
        delete :destroy, @params
      end

      it do
        flash[:error].should_not be_nil
        flash[:error].should == "Nenhum convite para ser removido."
      end

      it 'Should be redirected to user home' do
        response.should redirect_to(home_user_path(@user))
      end
    end

    context 'Destroy invitations in batch' do
      before do
        UserSession.create(@user)
        @friends = (1..5).collect { Factory(:user) }
        @friends = @friends.collect { |f| "#{f.id},"}.to_s
        @emails = (1..5).collect { |i| "email#{i}@mail.com" }
        @emails = @emails.collect{ |e| "#{e},"}.to_s

        # Params to create invitations
        @invitation_params = {:locale => 'pt-BR'}
        @invitation_params.store('emails', @emails)
        @invitation_params.store('friend_id', @friends)
        InvitationsUtil.process_invites(@invitation_params, @user)

        # Request params
        @invitations = @user.invitations.collect{ |i| i.id }
        @friendship_requests = @user.friendships.requested.collect { |f| f.id }

        @params = {:locale => 'pt-BR'}
        @params.store(:invitations, @invitations)
        @params.store(:friendship_requests, @friendship_requests)
      end

      it "Should be redirected to user user friendship with error message" do
        @params = {:locale => 'pt-BR'}
        post :destroy_invitations, @params
        response.should redirect_to(new_user_friendship_path(@user))
        flash[:error].should_not be_nil
        flash[:error].should == "Nenhum convite foi selecionado para remoção."
      end

      it "should be redirected to user user friendship with a sucess message" do
        post :destroy_invitations, @params
        response.should redirect_to(new_user_friendship_path(@user))
        flash[:notice].should_not be_nil
        flash[:notice].should == "Os convites foram removidos com sucesso."
      end

      it "should be destroy all invitations" do
        expect {
          post :destroy_invitations, @params
        }.should change{ Invitation.all.count }.from(5).to(0)
        Friendship.all.count.should == 0
      end
    end
  end
end

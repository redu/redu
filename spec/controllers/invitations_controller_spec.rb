require 'spec_helper'
require 'authlogic/test_case'

describe InvitationsController do
  include Authlogic::TestCase

  before do
    User.maintain_sessions = false
    activate_authlogic
    @user = Factory(:user)
    @params = {:locale => "pt-BR"}
  end

  context "Friendship invitations - " do
    before do
      @friend = Factory(:user)
      @invitation_params = {'emails' => 'example@email.com',
                            'friend_id' => @friend.id }

      controller.process_invites(@invitation_params, @user)
      @invitation = @user.invitations.last
      @params.store(:id, @invitation.id)
    end

    context "Show action" do
      before do
        UserSession.create(@friend)
      end

      it 'The Invitation must be accepted automatically, when user were logged' do
        get :show, @params
        @friend.friendships.count.should == 1
        @user.friendships.count.should == 1
        Invitation.all.count.should == 0
      end

      it 'Redirect to user_home_path when user were logged' do
        get :show, @params
        response.should redirect_to(home_user_path(@friend))
      end

      context 'Invitation already accepted' do
        before do
          @invitation.accept!(@friend)
          get :show, @params
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

        it 'Redirect to home_path' do
          response.should redirect_to(home_path)
        end
      end
    end

    context 'User not logged:' do
      before do
        @user = Factory(:user)
        controller.process_invites(@invitation_params, @user)
        @params = {:locale => "pt-BR",
                   :id => @invitation.id}

        get :show, @params
      end

      it 'redirect to invitation_path' do
        response.should be_success
      end

      it 'assigns user' do
        assigns(:invitation_user).should == @invitation.user
      end

      it 'assigns contacts count' do
        assigns(:contacts)[:total].should == @user.friends.count
      end

      it 'assigns courses members counts' do
        uca = @user.user_course_associations.approved
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

    context 'Destroy invitations in batch' do
      before do
        UserSession.create(@user)
        Friendship.destroy_all
        Invitation.destroy_all
        @friends = (1..5).collect { Factory(:user) }
        @emails = (1..@friends.count).collect { |i| "email#{i}@mail.com" }
        @friends = @friends.collect { |f| "#{f.id},"}.to_s
        @emails = @emails.collect{ |e| "#{e},"}.to_s

        # Params to create invitations
        @invitation_params = {'emails' => @emails,
                              'friend_id' => @friends}
        controller.process_invites(@invitation_params, @user)

        # Request params
        @invitations = @user.invitations.collect{ |i| i.id }
        @friendship_requests = @user.friendships.requested.collect { |f| f.id }

        @params = {:locale => 'pt-BR'}
      end

      it "Should be redirected to user user friendship with error message" do
        post :destroy_invitations, @params
        response.should redirect_to(new_user_friendship_path(@user))
        flash[:error].should_not be_nil
        flash[:error].should == "Nenhum convite foi selecionado para remoção."
      end

      it "should be redirected to user user friendship with a sucess message" do
        @params.store(:invitations_ids, @invitations)
        @params.store(:friendship_requests, @friendship_requests)
        post :destroy_invitations, @params

        response.should redirect_to(new_user_friendship_path(@user))
        flash[:notice].should_not be_nil
        flash[:notice].should == "Os convites foram removidos com sucesso."
      end

      it "should be destroy all invitations" do
        @params.store(:invitations_ids, @invitations)
        expect {
          post :destroy_invitations, @params
        }.should change(Invitation, :count).by(-5)
      end

      it "should be destroy all friendship requests(requested and pending)" do
        @params.store(:friendship_requests, @friendship_requests)
        expect {
          post :destroy_invitations, @params
        }.should change(Friendship, :count).by(-10)
      end
    end
  end

  context 'Resend email' do
    before do
      UserSession.create(@user)
      @invitation = Invitation.invite(:user => @user,
                                      :hostable => @user,
                                      :email => 'email@example.com')
      @params.store(:format, 'js')
      @params.store(:id, @invitation.id)
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
      @invitation = Invitation.invite(:user => @user,
                                      :hostable => @user,
                                      :email => 'email@example.com')
      @params.store(:id, @invitation.id)
      delete :destroy, @params
    end

    it 'Invitations should be deleted' do
      @new_invitation = Invitation.invite(:user => @user,
                                          :hostable => @user,
                                          :email => 'email@example.com')
      @params.store(:id, @new_invitation.id)
      expect {
        delete :destroy, @params
      }.should change(Invitation, :count).by(-1)
    end

    it 'sucess message should be presented' do
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
      end

      it 'Should be redirected to not found' do
        expect {
          delete :destroy, @params
        }.should raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end

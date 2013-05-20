# -*- encoding : utf-8 -*-
require 'spec_helper'

describe AuthenticationsController do
  describe "GET create" do
    context 'when successfully authenticates' do
      context 'and connects with existent user' do
        let(:user) { Factory(:user) }
        let(:omniauth) do
          OmniAuth.config.mock_auth[:some_provider].merge({
            :info => {
              :email => user.email,
              :first_name => user.first_name,
              :last_name => user.last_name
            }
          })
        end

        before do
          request.env['omniauth.auth'] = omniauth
          get :create, :locale => 'pt-BR'
        end

        it "should set current user" do
          UserSession.find.user.should == user
        end

        it { should set_the_flash.
             to(I18n.t("facebook_connect_account_association")) }
        it { should redirect_to(controller.home_user_path(user))  }
      end

      context 'and do not connect with existent user' do
        let(:omniauth) { OmniAuth.config.mock_auth[:some_provider] }

        before do
          request.env['omniauth.auth'] = omniauth
          get :create, :locale => 'pt-BR'
        end

        it "should set current user" do
          UserSession.find.user.should == User.last
        end

        it { should set_the_flash.to(I18n.t("thanks_youre_now_logged_in")) }
        it { should redirect_to(controller.home_user_path(User.last))  }
      end
    end

    context 'when do not authenticate' do
      let(:omniauth) do
        OmniAuth.config.mock_auth[:some_provider].merge({
          :info => {
            :email => 'invalid.email',
            :first_name => 'John',
            :last_name => 'Doe'
          }
        })
      end

      before do
        request.env['omniauth.auth'] = omniauth
        get :create, :locale => 'pt-BR'
      end

      it "should not set current user" do
        UserSession.find.should be_nil
      end

      it "should assign @user_session" do
        assigns[:user_session].should_not be_nil
      end

      it "should assign @user" do
        assigns[:user].should_not be_nil
        assigns[:user].should be_a User
      end

      it "should assign @user with omniauth param" do
        assigns[:user].email.should == omniauth[:info][:email]
        assigns[:user].first_name.should == omniauth[:info][:first_name]
        assigns[:user].last_name.should == omniauth[:info][:last_name]
      end

      it "should set param opened_signup_modal to 'open-me'" do
        controller.params[:opened_signup_modal].should_not be_nil
        controller.params[:opened_signup_modal].should == "open-me"
      end

      it { should set_the_flash.to(I18n.t("facebook_connect_error")) }
      it { should render_template('base/site_index') }
    end

    context 'with aditional params' do
      before do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:some_provider]
      end

      context "when there is a state param" do
        context "and this param is known by the app" do
          context "with current url details" do
            before do
              @apps_portal_url = "#{Redu::Application.config.redu_services[:apps][:url]}/apps/73"
              get :create, :locale => 'pt-BR', :state => @apps_portal_url
              @user = User.find_by_email(request.env['omniauth.auth'][:info][:email])
            end

            it { should redirect_to(@apps_portal_url)  }
          end
        end

        context "and this param is NOT known by the app" do
          before do
            get :create, :locale => 'pt-BR', :state => "http://hack.com"
            @user = User.find_by_email(request.env['omniauth.auth'][:info][:email])
          end

          it { should redirect_to(controller.home_user_path(@user))  }
        end
      end

      context "when there is a return_to param" do
        before do
          session[:return_to] = "http://someplace.com"
          get :create, :locale => 'pt-BR'
          @user = User.find_by_email(request.env['omniauth.auth'][:info][:email])
        end

        it { should redirect_to("http://someplace.com")  }
      end

      context "when user has an invitation to course" do
        let(:course) { Factory(:course) }
        let(:invite) do
          Factory(:user_course_invitation, :course => course,
                  :email => request.env['omniauth.auth'][:info][:email])
        end

        before do
          invite.invite!
          @state = { :invitation_token => invite.token }.to_json
        end

        it "invites the loged user to the course identified by the token invitation" do
          expect {
            get :create, :locale => 'pt-BR', :state => @state
          }.to change(UserCourseAssociation, :count).by(1)
        end
      end

      context "when user has a friendship request" do
        let(:invitation) do
          Invitation.invite(:user => @host, :hostable => @host,
                            :email => 'email@example.com')
        end

        before do
          @host = Factory(:user)
          state = { :friendship_invitation_token => invitation.token }.to_json
          get :create, :locale => 'pt-BR', :state => state
          @user = User.find_by_email(request.env['omniauth.auth'][:info][:email])
        end

        it "should empty invitations 'cause the only one was already accepted" do
          Invitation.all.should be_empty
        end

        it "should create friendship request" do
          @host.friendships.requested.should_not be_empty
          @user.friendships.pending.should_not be_empty
        end
      end
    end
  end

  describe "GET fallback" do
    before do
      get :fallback, :locale => 'pt-BR'
    end

    it { should set_the_flash.to(I18n.t("you_need_give_us_access_to_your_facebook_data")) }
    it { should redirect_to(controller.home_path)  }
  end
end

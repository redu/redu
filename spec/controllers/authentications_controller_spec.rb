require 'spec_helper'
require 'authlogic/test_case'

describe AuthenticationsController do
  describe "GET create" do

    before do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
    end

    context "when authentication already exists" do
      before do
        @user = Factory.create(:user)
        auth = Factory.create(:authentication, :user => @user)
        request.env['omniauth.auth'][:uid] = auth.uid
        get :create, :locale => 'pt-BR'
      end

      it "should set current user" do
        UserSession.find.should_not be_nil
      end

      it { should set_the_flash.to(I18n.t("thanks_youre_now_logged_in")) }
      it { should redirect_to(home_user_path(@user))  }
    end # context "when authentication already exists"

    context "when authentication does not exist" do

      context "and there's a Redu account associated to email in auth hash" do

        context "which is activated" do
          before do
            @user = Factory.create(:user)
            @user.update_attributes(:activated_at => 2.months.ago)
            request.env['omniauth.auth'][:info][:email] = @user.email
            get :create, :locale => 'pt-BR'
            provider = request.env['omniauth.auth'][:provider]
            uid = request.env['omniauth.auth'][:uid]
            @created_auth = Authentication.find_by_provider_and_uid(provider, uid)
          end

          it "should create a new authentication and associate it to existing account" do
            @created_auth.should_not be_nil
            @created_auth.user.should == @user
          end

          it "should not change user settings propriety" do
            @user.settings.should == @created_auth.user.settings
          end

          it "should not change activated_at property" do
            user = @created_auth.user
            user.activated_at.to_date.should == @user.activated_at.to_date
          end

          it "should set current user" do
            UserSession.find.should_not be_nil
          end

          it { should set_the_flash.to(I18n.t("facebook_connect_account_association")) }
          it { should redirect_to(home_user_path(@user))  }
        end

        context "which is not activated" do
          before do
            @user = Factory.create(:user)
            @user.update_attributes(:activated_at => nil)
            request.env['omniauth.auth'][:info][:email] = @user.email
            @provider = request.env['omniauth.auth'][:provider]
            @uid = request.env['omniauth.auth'][:uid]
          end

          it "should activate account when user connects with Facebook" do
            get :create, :locale => 'pt-BR'
            @created_auth = Authentication.find_by_provider_and_uid(@provider, @uid)
            user = @created_auth.user
            user.activated_at.should_not be_nil
          end

          it "should set current user" do
            get :create, :locale => 'pt-BR'
            UserSession.find.should_not be_nil
          end

          context "and activation time limit has expired" do
            before do
              @user.update_attributes(:created_at => 2.months.ago)
              get :create, :locale => 'pt-BR'
              @created_auth = Authentication.find_by_provider_and_uid(@provider, @uid)
            end

            it "should activate account when user connects with Facebook" do
              user = @created_auth.user
              user.activated_at.should_not be_nil
            end

            it "should set current user" do
              UserSession.find.should_not be_nil
            end
          end # context "and activation time limit has expired"
        end # context "which is not activated"
      end # context "and there's a Redu account associated to email in auth hash"

      context "and there's not a Redu account associated to email in auth hash" do
        before do
          get :create, :locale => 'pt-BR'
          @user = User.find_by_email(request.env['omniauth.auth'][:info][:email])
        end

        it "should create a new Redu account using the email" do
          @user.should_not be_nil
        end

        it "should create the user's settings properly" do
          @user.settings.should_not be_nil
        end

        it "should activate user's account" do
          @user.activated_at.should_not be_nil
        end

        it "should set current user" do
          UserSession.find.should_not be_nil
        end

        it { should set_the_flash.to(I18n.t("facebook_connect_new_user")) }
        it { should redirect_to(home_user_path(@user))  }
      end # context "and there's not a Redu account associated to email in auth hash"
    end # context "when authentication does not exist"

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

        it { should redirect_to(home_user_path(@user))  }
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
        }.should change(UserCourseAssociation, :count).by(1)
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

  describe "GET fallback" do
    before do
      get :fallback, :locale => 'pt-BR'
    end

    it { should set_the_flash.to(I18n.t("you_need_give_us_access_to_your_facebook_data")) }
    it { should redirect_to(home_path)  }
  end

end

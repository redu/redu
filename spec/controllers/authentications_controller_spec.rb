require 'spec_helper'

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

      it { should set_the_flash.to(I18n.t("thanks_youre_now_logged_in")) }
      it { should redirect_to(home_user_path(@user))  }
    end

    context "when authentication does not exist" do

      context "and there's a Redu account associated to email in auth hash" do
        before do
          @user = Factory.create(:user)
          request.env['omniauth.auth'][:info][:email] = @user.email
          get :create, :locale => 'pt-BR'
        end

        it "should create a new authentication and associate it to existing account" do
          provider = request.env['omniauth.auth'][:provider]
          uid = request.env['omniauth.auth'][:uid]
          created_auth = Authentication.find_by_provider_and_uid(provider, uid)
          created_auth.should_not be_nil
          created_auth.user.should == @user
        end

        it "should not change user settings propriety" do
          provider = request.env['omniauth.auth'][:provider]
          uid = request.env['omniauth.auth'][:uid]
          created_auth = Authentication.find_by_provider_and_uid(provider, uid)
          @user.settings.should == created_auth.user.settings
        end

        it { should set_the_flash.to(I18n.t("facebook_connect_account_association")) }
        it { should redirect_to(home_user_path(@user))  }

        context "which is activated" do

        end

        context "which is not activated" do

        end
      end

      context "and there's not a Redu account associated to email in auth hash" do
        before do
          get :create, :locale => 'pt-BR'
          @user = User.find_by_email(request.env['omniauth.auth'][:info][:email])
        end

        it "should create a new Redu account using the email" do
          @user.should_not be_nil
        end

        it "should create the user's settings properly" do
          provider = request.env['omniauth.auth'][:provider]
          uid = request.env['omniauth.auth'][:uid]
          created_auth = Authentication.find_by_provider_and_uid(provider, uid)
          created_auth.user.settings.should_not be_nil
        end

        it { should set_the_flash.to(I18n.t("facebook_connect_new_user")) }
        it { should redirect_to(home_user_path(@user))  }
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

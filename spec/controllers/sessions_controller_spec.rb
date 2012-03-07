require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

# Omniauth testing.
require 'omniauth-facebook'

describe SessionsController do
  before do
    @user = Factory(:user)
  end

  context "POST create" do
    context "with a token (:invitation)" do
      before do
        course = Factory(:course)
        @invite = Factory(:user_course_invitation, :email => @user.email,
                         :course => course)
        @invite.invite!
      end

      context "when logging in successful" do
        before do
          @post_params = {:locale => 'pt-BR', :invitation_token => @invite.token,
            :user_session => { :remember_me => "0", :password => @user.password,
                               :login => @user.login}}
        end

        it "invites the loged user to the course identified by the token invitation" do
          expect {
            post :create, @post_params
          }.should change(UserCourseAssociation, :count).by(1)
          @invite.reload.should be_approved
        end
      end

      context "when logging with failure" do
        before do
          @post_params = {:locale => 'pt-BR', :invitation_token => @invite.token,
            :user_session => { :remember_me => "0", :password => "wrong-pass",
                               :login => @user.login}}
          post :create, @post_params
        end

        it "assigns environment" do
          assigns[:environment].should == @invite.course.environment
        end
        it "assigns course" do
          assigns[:course].should == @invite.course
        end
        it "assigns user_course_invitation" do
          assigns[:user_course_invitation].should == @invite
        end

        it "re-renders UserCourseInvitations#show" do
          response.should render_template('user_course_invitations/show')
        end

      end
    end
  end

  context "GET destroy (logout)" do
    context "when current_user is NOT nil" do
      before do
        @user = Factory(:user)
        activate_authlogic
        UserSession.create @user
        get :destroy, { :locale => "pt-BR" }
      end

      it "destroys the user_session" do
        UserSession.find.should be_nil
      end

      it "redirects to home_path" do
        response.should redirect_to(home_path)
      end
    end

    context "when current_user is nil" do
      it "redirects to home_path" do
        get :destroy, { :locale => "pt-BR" }
        response.should redirect_to(home_path)
      end
    end
  end

  describe :omniauth do
    before :each do
      #@request = double('Request')
      @request.stub(:params) { {} }
      @request.stub(:cookies) { {} }

      @client_id = '123'
      @client_secret = '53cr3tz'
    end

    subject do
      args = [@client_id, @client_scret, @options].compact
      OmniAuth::Strategies::Facebook.new(nil, *args).tap do |strategy|
        strategy.stub(:request) { @request }
      end
    end #subject

    context 'user has authenticated in facebook' do
      context 'user is not a Redu user' do
        it 'should detect that user is not registered' do
          @raw_info = { 'email' => 'unregistered@example.com' }
          subject.stub(:raw_info) { @raw_info }
          user = User.find_by_email(subject.raw_info['email'])
          user.should be_nil
        end

        it 'should create user from facebook auth hash' do
          
        end
      end

      context 'user is a Redu user' do
      end
    end
  end #describe :omniauth
end

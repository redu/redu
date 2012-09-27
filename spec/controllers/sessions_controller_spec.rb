require 'spec_helper'
require 'authlogic/test_case'

describe SessionsController do
  include Authlogic::TestCase

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
                          :format => "js",
                          :user_session => { :remember_me => "0", :password => @user.password,
                                             :login => @user.login}}
        end

        it "invites the loged user to the course identified by the token invitation" do
          expect {
            post :create, @post_params
          }.should change(UserCourseAssociation, :count).by(1)
        end
      end

      context "when logging with failure" do
        before do
          @post_params = {:locale => 'pt-BR', :invitation_token => @invite.token,
                          :format => "js",
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

    context "Request with friendship_invitation_token" do
      before do
        @email = 'mail@example.com'
        @host = Factory(:user)
        @invitation = Invitation.invite(:user => @host,
                                        :hostable => @host,
                                        :email => 'email@example.com')
      end

      context "Login successfully" do
        before do
          @post_params = {:locale => 'pt-BR',
                          :friendship_invitation_token => @invitation.token,
                          :format => "js",
                          :user_session => { :remember_me => "0",
                                             :password => @user.password,
                                             :login => @user.login}}
          post :create, @post_params
        end

        it "invite should be accepted (Invitation should be destroyed)" do
          Invitation.all.should be_empty
        end

        it "should redirect do home-user-path" do
          response.body.should == "window.location = '#{ home_user_path(@user) }'"
        end

        it "friendship request should be created" do
          @host.friendships.requested.should_not be_empty
          @user.friendships.pending.should_not be_empty
        end
      end

      context "User login params validation fail" do
        before do
          @post_params = {:locale => 'pt-BR',
                          :friendship_invitation_token => @invitation.token,
                          :format => "js",
                          :user_session => {
                            :remember_me => "0",
                            :password => "wrong-pass",
                            :login => @user.login}
          }
          post :create, @post_params
        end

        it "assigns user" do
          assigns(:invitation_user).should == @invitation.user
        end

        it 'assigns contacts' do
          assigns(:contacts)[:total].should == @invitation.user.friends.count
        end

        it 'assigns courses' do
          uca = UserCourseAssociation.where(:user_id => @invitation.user).approved
          @courses = { :total => @invitation.user.courses.count,
                       :environment_admin => uca.with_roles([:environment_admin]).count,
                       :tutor => uca.with_roles([:tutor]).count,
                       :teacher => uca.with_roles([:teacher]).count }

          assigns(:courses)[:total].should == @courses[:total]
          assigns(:courses)[:environment_admin].should == @courses[:environment_admin]
          assigns(:courses)[:tutor].should == @courses[:tutor]
          assigns(:courses)[:teacher].should == @courses[:teacher]
        end

        it "should render invitations#show template" do
          response.should render_template("invitations/show")
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
end

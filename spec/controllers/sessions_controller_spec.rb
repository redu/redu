# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'authlogic/test_case'

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
        context "and the request is via AJAX/JS" do
          before do
            @post_params = {:locale => 'pt-BR', :invitation_token => @invite.token,
                            :format => :js,
                            :user_session => { :remember_me => "0", :password => @user.password,
                                               :login => @user.login}}
          end

          it "invites the loged user to the course identified by the token invitation" do
            expect {
              post :create, @post_params
            }.to change(UserCourseAssociation, :count).by(1)
          end

          it "should redirect to home_user_path" do
            post :create, @post_params
            response.body.should == "window.location = '#{ controller.home_user_path(@user) }'"
          end
        end

        context "and the request is via HTML" do
          before do
            @post_params = {:locale => 'pt-BR',
                            :invitation_token => @invite.token,
                            :format => :html,
                            :user_session => { :remember_me => "0",
                                               :password => @user.password,
                                               :login => @user.login}}
          end

          it "invites the loged user to the course identified by the token invitation" do
            expect {
              post :create, @post_params
            }.to change(UserCourseAssociation, :count).by(1)
          end

          it "should redirect to home_user_path" do
            post :create, @post_params
            response.should redirect_to(controller.home_user_path(@user))
          end
        end
     end

      context "when logging with failure" do
        before do
          @post_params = {:locale => 'pt-BR', :invitation_token => @invite.token,
                          :format => :js,
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

    context "request with friendship_invitation_token" do
      before do
        @email = 'mail@example.com'
        @host = Factory(:user)
        @invitation = Invitation.invite(:user => @host,
                                        :hostable => @host,
                                        :email => 'email@example.com')
      end

      context "login successfully via AJAX request" do
        before do
          @post_params = {:locale => 'pt-BR',
                          :friendship_invitation_token => @invitation.token,
                          :format => :js,
                          :user_session => { :remember_me => "0",
                                             :password => @user.password,
                                             :login => @user.login}}
          post :create, @post_params
        end

        it "invite should be accepted (invitation should be destroyed)" do

          Invitation.all.should be_empty
        end

        it "should redirect do home-user-path" do
          response.body.should == "window.location = '#{ controller.home_user_path(@user) }'"
        end

        it "friendship request should be created" do
          @host.friendships.requested.should_not be_empty
          @user.friendships.pending.should_not be_empty
        end
      end

      context "login successfully via HTML request" do
        before do
          @post_params = {:locale => 'pt-BR',
                          :friendship_invitation_token => @invitation.token,
                          :user_session => { :remember_me => "0",
                                             :password => @user.password,
                                             :login => @user.login}}
          post :create, @post_params
        end

        it "invite should be accepted (invitation should be destroyed)" do
          Invitation.all.should be_empty
        end

        it "should redirect do home-user-path" do
          response.should redirect_to(controller.home_user_path(@user))
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
                          :format => :js,
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

    context "when registration had expired" do
      before do
        @user.deactivate
        @user.created_at = "2011-03-04".to_date
        @user.save
        post_params = {:locale => 'pt-BR', :format => :js,
                       :user_session => { :remember_me => "0",
                                          :password => @user.password,
                                          :login => @user.login}}
        post :create, post_params
      end

      it "should assign user_email" do
        assigns(:user_email).should == @user.email
      end

      it "should be success" do
        response.should be_success
      end
    end

    context "doesn't have any token" do
      context "and format.html" do
        before do
          post_params = {:locale => 'pt-BR',
                          :user_session => { :remember_me => "0",
                                             :password => "wrong-pass",
                                             :login => @user.login } }
          post :create, post_params
        end

        it "should re-render site_index" do
          response.should render_template("base/site_index")
        end
      end
    end
  end

  context "GET destroy(logout)" do
    context "when current_user is NOT nil" do
      before do
        @user = Factory(:user)
        login_as @user
        get :destroy, { :locale => "pt-BR" }
      end

      it "destroys the user_session" do
        UserSession.find.should be_nil
      end

      it "redirects to home_path" do
        response.should redirect_to(controller.home_path)
      end
    end

    context "when current_user is nil" do
      it "redirects to home_path" do
        get :destroy, { :locale => "pt-BR" }
        response.should redirect_to(controller.home_path)
      end
    end
  end

  context "GET new" do
    let(:user) { Factory(:user) }

    context "when there is not a current user" do
      context "with a mobile user agent" do
        before do
          mock_user_agent(:mobile => true)
          get :new, :locale => 'pt-BR'
        end

        it "should assign @user_session" do
          assigns[:user_session].should_not be_nil
          assigns[:user_session].should be_a UserSession
        end
      end

      context "with a non mobile user agent" do
        before do
          mock_user_agent(:mobile => false)
        end

        it "should redirect to application_path" do
          get :new, :locale => 'pt-BR'
          response.should redirect_to(controller.application_path)
        end
      end
    end

    context "when there is a current user" do
      before do
        login_as user

        get :new, :locale => 'pt-BR'
      end

      it "redirects to home_user_path" do
        response.should redirect_to(controller.home_user_path(user))
      end
    end
  end
end

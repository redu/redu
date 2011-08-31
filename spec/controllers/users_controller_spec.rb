require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe UsersController do

  before do
    users = (1..4).collect { Factory(:user) }
    users[0].be_friends_with(users[1])
    users[0].be_friends_with(users[2])
    users[0].be_friends_with(users[3])
    users[1].be_friends_with(users[0])
    users[2].be_friends_with(users[0])
    @friends = [users[1], users[2]]
    @user = users[0]
  end

  context "POST create" do

    context "when creating an account" do
      before do
        @post_params = { :locale => 'pt-BR',
          :user => { "birthday(1i)" => "1986", :tos => "1",
            :email_confirmation=> "email@example.com", "birthday(2i)" => "4",
            :password_confirmation => "password", "birthday(3i)" => "6",
            :last_name => "Doe", :password => "password",
            :login => "userlogin", :email => "email@example.com",
            :first_name => "John" } }
      end

      context "when successfull" do
        before do
          post :create, @post_params
        end

        it "creates a user_setting" do
          created_user = User.find_by_email(@post_params[:user][:email])
          created_user.should_not be_nil
          created_user.settings.should_not be_nil
          created_user.settings.view_mural.should == Privacy[:friends]
        end
      end

      context "with an invitation token" do
        context "and failing the validation" do
          before do
            course = Factory(:course)
            @invite = Factory(:user_course_invitation,
                              :email => "email@example.com", :course => course)
            @invite.invite!
            @post_params.store(:invitation_token, @invite.token)
            @post_params[:user][:password_confirmation] = "wrong-pass"
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

          it "re-renders Users#new" do
            response.should render_template('users/new')
          end
        end

        context "and the same email that was invited" do
          before do
            course = Factory(:course)
            @invite = Factory(:user_course_invitation,
                              :email => @post_params[:user][:email],
                              :course => course)
            @invite.invite!
            @post_params.store(:invitation_token, @invite.token)
          end

          it "invites the new user to the course identified by the token invitation" do
            expect {
              post :create, @post_params
            }.should change(UserCourseAssociation, :count).by(1)
            @invite.reload.should be_approved
            UserCourseAssociation.last.user.email.
              should == @post_params[:user][:email]
          end
        end

        context "and with a different email from the invited one" do

          before do
            @another_email = "newemail@example.com"
            course = Factory(:course)
            @invite = Factory(:user_course_invitation,
                              :email => @another_email,
                              :course => course)
            @invite.invite!
            @post_params.store(:invitation_token, @invite.token)
            @post_params[:user][:email] = @another_email
            @post_params[:user][:email_confirmation] = @another_email
          end

          it "invites the new user to the course identified by the token invitation" do
            expect {
              post :create, @post_params
            }.should change(UserCourseAssociation, :count).by(1)
            @invite.reload.should be_approved
            UserCourseAssociation.last.user.email.should == @another_email
          end

        end
      end
    end
  end

  context "POST update" do
    before do
      @user = Factory(:user)
      activate_authlogic
      UserSession.create @user

      @post_params = { :locale => "pt-BR", :id => @user.login, :user => {
        "birthday(1i)"=>"1991", "birthday(2i)"=>"6", "birthday(3i)"=>"8",
        :mobile => "", :last_name => "Last", :localization => "",
        :description => "", :first_name => "First" } }
    end

    context "when successful" do
      before do
        post :update, @post_params
      end

      it "updates the user" do
        @user.reload
        @user.first_name.should == @post_params[:user][:first_name]
        @user.last_name.should == @post_params[:user][:last_name]
      end

      it "redirects to edit_user_path" do
        response.should redirect_to(edit_user_path(@user))
      end
    end

    context "when failing" do
      before do
        @real_name = @user.first_name
        @post_params[:user][:first_name] = ""
        post :update, @post_params
      end

      it "does NOT update the user" do
        assigns[:user].errors.should_not be_empty
        @user.reload.first_name.should == @real_name
      end

      it "re-reders users/edit" do
        response.should render_template("users/edit")
      end

      context "to render form errors" do
        it "assigns @experience" do
          assigns[:experience].should_not be_nil
        end

        it "assigns @high_school" do
          assigns[:high_school].should_not be_nil
        end

        it "assigns @higher_education" do
          assigns[:higher_education].should_not be_nil
        end

        it "assigns @complementary_course" do
          assigns[:complementary_course].should_not be_nil
        end

        it "assigns @event_education" do
          assigns[:event_education].should_not be_nil
        end
      end
    end
  end

  context "POST update_account" do
    before do
      @user = Factory(:user)
      activate_authlogic
      UserSession.create @user

      @post_params = { :locale => "pt-BR", :current_password => @user.password,
        :id => @user.login, :user => {
        :email_confirmation => "new_email@example.com",
        :password_confirmation => "new-pass", :auto_status => "1",
        :notify_messages => "1", :notify_community_news => "1",
        :notify_followships => "1", :password => "new-pass",
        :settings_attributes => { :id  =>@user.settings.id,
          :view_mural => "1" }, :email => "new_email@example.com" } }
    end

    context "when successful" do
      before do
        post :update_account, @post_params
      end

      it "updates the user account informations" do
        authenticated = UserSession.new(:login => @user.login,:password => @post_params[:user][:password]).save
        authenticated.should be_true
        @user.reload.email.should == @post_params[:user][:email]
      end

      it "redirects to account_user_path" do
        response.should redirect_to(account_user_path(@user))
      end
    end

    context "when failing" do
      before do
        @post_params[:current_password] = "wrong-pass"
        post :update_account, @post_params
      end

      it "does NOT update the user account informations" do
        assigns[:user].errors.should_not be_empty
        authenticated = UserSession.new(:login => @user.login,:password => @post_params[:user][:password]).save
        authenticated.should_not be_true
        @user.reload.email.should_not == @post_params[:user][:email]
      end

      it "re-renders users/account" do
        response.should render_template("users/account")
      end
    end
  end

  context "POST destroy" do
    before do
      @user = Factory(:user)
      activate_authlogic
      UserSession.create @user

      @post_params = { :locale => "pt-BR", :id => @user.login }
    end

    it "destroys the user" do
      expect {
        post :destroy, @post_params
      }.should change(User, :count).by(-1)
    end

    it "redirects to site_index" do
        post :destroy, @post_params
        response.should redirect_to(home_path)
    end
  end

  context "GET home" do
    before do
      @user = Factory(:user)
      activate_authlogic
      UserSession.create @user

      @params = { :locale => "pt-BR", :id => @user.login }
      get :home, @params
    end

    [:friends, :friends_requisitions, :course_invitations, :statuses, :status,
      :contacts_recommendations].each do |var|
      it "assigns @#{var}" do
        assigns[var].should_not be_nil
      end
    end
  end

  context "GET curriculum" do
    before do
      @user = Factory(:user)
      activate_authlogic
      UserSession.create @user
      get :curriculum, { :locale => "pt-BR", :id => @user.login }
    end

    [:experience, :high_school, :higher_education,
      :complementary_course, :event_education].each do |v|
      it "assigns #{v}" do
        assigns[v].should_not be_nil
      end
    end
  end
end

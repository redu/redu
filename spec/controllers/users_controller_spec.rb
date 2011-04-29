require 'spec_helper'
require 'authlogic/test_case'

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
end

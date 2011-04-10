require 'spec_helper'

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
      end

      context "when logging" do
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

    end
  end

end

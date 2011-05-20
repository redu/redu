require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe UserCourseInvitationsController do
  before do
    User.maintain_sessions = false
    activate_authlogic
  end

  context "GET show" do
    before do
      course = Factory(:course)
      @invite = course.invite_by_email("email@example.com")
      @params = {:locale => 'pt-BR', :environment_id => course.environment.path,
        :course_id => course.id, :id => @invite.id }
    end

    context "when the user is logged in" do
      before do
        @logged_user = Factory(:user)
        UserSession.create @logged_user
        get :show, @params
      end

      it "accepts the invite" do
        @invite.reload.should be_approved
      end

      it "redirects to user's home" do
        response.should redirect_to(home_user_path(@logged_user))
      end

    end

    context "when the user is not logged in" do
      before do
        get :show, @params
      end

      it "do NOT accept the invite" do
        @invite.should be_invited
      end
    end

    context "when the invite was not used ('invited')" do
      before do
        get :show, @params
      end

      it "assigns the environment" do
        assigns[:environment].should == @invite.course.environment
      end

      it "assigns the course" do
        assigns[:course].should == @invite.course
      end

      it "assigns the user_course_association" do
        assigns[:user_course_invitation].should == @invite
      end

      it "assigns the user_session" do
        assigns[:user_session].should_not be_nil
      end
    end
    context "when the invite was used ('approved')" do
      before do
        @invite.user = Factory(:user)
        @invite.accept!
        get :show, @params
      end

      it "redirects to site index" do
        response.should redirect_to(application_path)
      end
    end
  end
end

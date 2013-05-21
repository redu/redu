# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'authlogic/test_case'

describe UserCourseInvitationsController do
  context "GET show" do
    before do
      @course = FactoryGirl.create(:course)
      @invite = @course.invite_by_email("email@example.com")
      @params = {:locale => 'pt-BR', :environment_id => @course.environment.path,
        :course_id => @course.path, :id => @invite.id }
    end

    context "when the user is logged in" do
      before do
        @logged_user = FactoryGirl.create(:user)
        login_as @logged_user
        get :show, @params
      end

      it "accepts the invite" do
        association = @logged_user.get_association_with(@course)
        association.should be_invited
      end

      it "redirects to user's home" do
        response.should redirect_to(controller.home_user_path(@logged_user))
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
  end
end

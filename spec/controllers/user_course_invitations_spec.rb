require 'spec_helper'

describe UserCourseInvitationsController do
  context "GET show" do
    before do
      course = Factory(:course)
      @invite = course.invite_by_email("email@example.com")
      @params = {:locale => 'pt-BR', :course_id => course.id, :id => @invite.id }
      get :show, @params
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

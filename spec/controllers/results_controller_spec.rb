require 'spec_helper'
require 'authlogic/test_case'

describe ResultsController do
  include Authlogic::TestCase
  before do
    User.maintain_sessions = false
    @space = Factory(:space)
    activate_authlogic

    @subject = Factory(:subject, :owner => @space.owner,
                       :space => @space, :finalized => true,
                       :visible => true)
    @exercise = Factory(:complete_exercise)
    @lecture = Factory(:lecture,:subject => @subject, :lectureable => @exercise,
                       :owner => @space.owner)

    @user = Factory(:user)
    @space.course.join(@user)
    UserSession.create @user
  end

  context "POST create" do
    before do
      @params = { :locale => 'pt-BR', :format => :html }
      @params.merge!( :exercise_id => @exercise.id )
    end

    it "creates the Result when does not exists" do
      Exercise.any_instance.should_receive(:start_for).with(@user)
      post :create, @params
    end

    it "redirects to the first question" do
      post :create, @params
      response.should \
        redirect_to(exercise_question_path(@exercise, @exercise.questions.first))
    end

    it "updates the Result when it exists" do
      @exercise.start_for(@user)
      expect {
        post :create, @params
      }.should_not change(Result, :count)
    end
  end
end

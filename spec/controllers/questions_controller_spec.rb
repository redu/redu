require 'spec_helper'
require 'authlogic/test_case'

describe QuestionsController do
  include Authlogic::TestCase
  before do
    User.maintain_sessions = false
    @space = Factory(:space)
    activate_authlogic

    @subject = Factory(:subject, :owner => @space.owner,
                       :space => @space, :finalized => true,
                       :visible => true)
    @exercise = Factory(:complete_exercise)
    @questions = @exercise.questions
    @lecture = Factory(:lecture,:subject => @subject, :lectureable => @exercise,
                       :owner => @space.owner)

    @user = Factory(:user)
    @space.course.join(@user)
    UserSession.create @user
  end

  context "when GET show" do
    before do
      @params = { :locale => 'pt-BR', :format => :html }
      @params.merge!({ :exercise_id => @exercise.id,
                       :id => @questions.first.id })
    end

    it "should load exercise" do
      get :show, @params
      assigns[:exercise].should_not be_nil
    end

    it "should load hierarchy" do
      get :show, @params
      assigns[:lecture].should_not be_nil
      assigns[:subject].should_not be_nil
      assigns[:space].should_not be_nil
      assigns[:course].should_not be_nil
      assigns[:environment].should_not be_nil
    end

    it "should load question" do
      get :show, @params
      assigns[:question].should_not be_nil
    end

    it "should load the first and last question" do
      get :show, @params
      assigns[:first_question].should_not be_nil
      assigns[:last_question].should_not be_nil
    end
  end
end

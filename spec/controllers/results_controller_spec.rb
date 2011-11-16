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

  context "POST update" do
    before do
      @result = @exercise.start_for(@user)
      @params = { :locale => 'pt-BR', :format => :html }
      @params.merge!({:exercise_id => @exercise.id, :id => @result.id})
    end

    it "should call finalize for" do
      Exercise.any_instance.should_receive(:finalize_for).with(@user)
      post :update, @params
    end

    it "should redirect to lectures#show" do
      post :update, @params
      response.should redirect_to \
        space_subject_lecture_path(@space, @subject, @lecture)
    end
  end

  context "get index" do
    before do
      @results = 5.times.collect {
        Factory(:result, :exercise => @exercise, :state => 'finalized',
                :grade => 10, :started_at => Time.zone.now,
                :finalized_at => Time.zone.now.advance(:minutes => 30),
                :duration => 30 * 60 * 60)
      }

      @params = { :locale => 'pt-BR', :format => :html }
      @params.merge!({ :exercise_id => @exercise.id })
    end

    it "should load the resulst" do
      post :index, @params
      assigns[:results].should_not be_nil
    end

    it "should load the correct results" do
      post :index, @params
      assigns[:results].to_set.should == @results.to_set
    end
  end
end

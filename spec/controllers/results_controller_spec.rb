# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'authlogic/test_case'

describe ResultsController do
  before do
    @space = FactoryGirl.create(:space)
    @course = @space.course
    @owner = @space.owner

    @subject = FactoryGirl.create(:subject, :owner => @space.owner,
                       :space => @space, :finalized => true,
                       :visible => true)
    @exercise = FactoryGirl.create(:complete_exercise)
    @lecture = FactoryGirl.create(:lecture,:subject => @subject, :lectureable => @exercise,
                       :owner => @space.owner)

    @user = FactoryGirl.create(:user)
    @space.course.join(@user)
    login_as @user
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
        redirect_to(controller.exercise_question_path(@exercise, @exercise.questions.first))
    end

    it "updates the Result when it exists" do
      @exercise.start_for(@user)
      expect {
        post :create, @params
      }.to_not change(Result, :count)
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

    xit "should call mark_as_done_for" do
      Lecture.any_instance.should_receive('mark_as_done_for!')
      post :update, @params
    end

    it "should redirect to lectures#show" do
      post :update, @params
      response.should redirect_to \
        controller.space_subject_lecture_path(@space, @subject, @lecture)
    end
  end

  context "get index" do
    before do
      @course.change_role(@user, Role[:teacher])
      @results = 5.times.collect {
        FactoryGirl.create(:result, :exercise => @exercise, :state => 'finalized',
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

  context "GET edit" do
    before do
      @result = @exercise.start_for(@user)
      @params = { :locale => 'pt-BR', :format => :html}
      @params.merge!({ :exercise_id => @exercise.id, :id => @result.id })
    end

    it "should load exercise" do
      get :edit, @params
      assigns[:exercise].should_not be_nil
    end

    it "should load hierarchy" do
      get :edit, @params
      assigns[:lecture].should_not be_nil
      assigns[:subject].should_not be_nil
      assigns[:space].should_not be_nil
      assigns[:course].should_not be_nil
      assigns[:environment].should_not be_nil
    end

    it "should load the first and last question" do
      get :edit, @params
      assigns[:first_question].should_not be_nil
      assigns[:last_question].should_not be_nil
    end

    it "should render questions#show" do
      get :edit, @params
      response.should render_template('questions/show')
    end
  end
end

# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'authlogic/test_case'

describe ChoicesController do
  before do
    @space = FactoryBot.create(:space)

    @subject = FactoryBot.create(:subject, :owner => @space.owner,
                       :space => @space, :finalized => true,
                       :visible => true)
    @exercise = FactoryBot.create(:complete_exercise)
    @questions = @exercise.questions
    @lecture = FactoryBot.create(:lecture,:subject => @subject, :lectureable => @exercise,
                       :owner => @space.owner)

    @user = FactoryBot.create(:user)
    @space.course.join(@user)
    login_as @user
  end

  context "POST create" do
    before do
      @exercise.start_for(@user)
      @alternative = @questions.first.alternatives.first
      @question = @questions.first
      @params = { :locale => 'pt-BR', :format => :js }
      @params.merge!(:exercise_id => @exercise.id,
                     :question_id => @question.id,
                     :choice => { :alternative_id => @alternative.id })
    end

    it "should load the exercise" do
      post :create, @params
      assigns[:exercise].should_not be_nil
    end

    it "should load the question" do
      post :create, @params
      assigns[:question].should_not be_nil
    end

    it "should create the choice" do
      expect {
        post :create, @params
      }.to change(Choice, :count).by(1)
    end

    it "should not double the choice" do
      post :create, @params

      expect {
        post :create, @params
      }.to_not change(Choice, :count)
    end

    it "should render questions/choice_form" do
      post :create, @params
      response.should render_template("questions/_choice_form")
    end

    context "when last question" do
      before do
        @last = @questions.last
        @params.merge!({:question_id => @last.id, :commit => nil,
                        :choice => { :alternative_id => @last.alternatives.first},
                        :commit => "Finalizar"})
      end

      it "should redirect to results edit" do
        result = @exercise.start_for(@user)
        post :create, @params
        response.body.should == "window.location = '#{ controller.edit_exercise_result_path(@exercise, result) }'"
      end
    end

    context "when there is no answer" do
      before do
        @params.delete(:choice)
      end

      it "should not raise error" do
        expect {
          post :create, @params
        }.to_not raise_error
      end

      it "should render question/choice_form" do
        post :create, @params
        response.should render_template("questions/_choice_form")
      end
    end
  end
end

# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'authlogic/test_case'

describe ExperiencesController do
  before do
    @user = Factory(:user)
    login_as @user
  end

  describe "POST 'create'" do
    before do
      @post_params = { :locale => "pt-BR", :format => "js",
        :user_id => @user.id, :experience =>
        { :title => "Developer", :company => "Company",
          :start_date => Date.today - 5.months, :current => "1",
          :end_date =>  Date.today - 5.months,
          :description => "Lorem ipsum dolor sit amet, consectetur magna aliqua." }}
      end
    context "when success" do
      it "should be successful" do
        post :create, @post_params
        response.should be_success
      end

      it "creates an experience to the logged user" do
        expect {
          post :create, @post_params
        }.to change(Experience, :count).by(1)
        Experience.last.user.should == @user
      end

      context "when is a current experience" do
        before do
          @post_params[:experience][:current] = "1"
          @post_params[:experience]["end_date(1i)"] = "2011"
          @post_params[:experience]["end_date(2i)"] = "7"
          @post_params[:experience]["end_date(3i)"] = "1"
          @post_params[:experience].delete :end_date
          post :create, @post_params
        end

        it "removes the end_date value" do
          Experience.last.end_date.should be_nil
        end

      end
    end

    context "when failing" do
      before do
        @post_params[:experience][:current] = "0"
        @post_params[:experience][:end_date] = ""
      end

      it "does NOT create an experience to the logged user" do
        expect {
          post :create, @post_params
        }.to_not change(Experience, :count)
      end
    end
  end

  describe "GET 'edit'" do
    before do
      @experience = Factory(:experience, :user => @user)
      @params = { :locale => "pt-BR", :format => "js", :user_id => @user.id,
                  :id => @experience.id }
      get :edit, @params
    end

    it "should be successful" do
      response.should be_success
    end

    it "assings @experience" do
      assigns[:experience].should_not be_nil
    end
  end

  describe "POST 'update'" do
    before do
      @experience = Factory(:experience, :user => @user)
      @post_params = { :locale => "pt-BR", :format => "js",
                       :user_id => @user.id, :id => @experience.id,
                       :experience => { :title => "Writer" }}
    end
    context "when success" do
      before do
        post :update, @post_params
      end

      it "should be successful" do
        response.should be_success
      end

      it "assings @experience" do
        assigns[:experience].should_not be_nil
      end

      it "updates the experience" do
        @experience.reload.title.should == @post_params[:experience][:title]
      end

      context "when is a current experience" do
        before do
          @post_params[:experience][:current] = "1"
          @post_params[:experience]["end_date(1i)"] = "2011"
          @post_params[:experience]["end_date(2i)"] = "7"
          @post_params[:experience]["end_date(3i)"] = "1"
          post :update, @post_params
        end

        it "removes the end_date value" do
          Experience.last.end_date.should be_nil
        end

      end
    end

    context "when failing" do
      before do
        @real_current = @experience.current
        @real_end_date = @experience.end_date
        @post_params[:experience][:current] = "0"
        @post_params[:experience][:end_date] = ""
        post :update, @post_params
      end

      it "assings @experience" do
        assigns[:experience].should_not be_nil
      end

      it "does NOT updates the experience" do
        assigns[:experience].should_not be_valid
        @experience.reload.current.should == @real_current
        @experience.reload.end_date.should == @real_end_date
      end
    end
  end

  describe "POST 'destroy'" do
    before do
      @experience = Factory(:experience, :user => @user)
      @post_params = { :locale => "pt-BR", :format => "js",
                       :user_id => @user.id, :id => @experience.id }
    end

    it "should be successful" do
      post :destroy, @post_params
      response.should be_success
    end

    it "destroys the experience" do
      expect {
        post :destroy, @post_params
      }.to change(Experience, :count).by(-1)
    end
  end

end

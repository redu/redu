require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe EnvironmentsController do
  context "when creating a paid Environment" do
    before do
      User.maintain_sessions = false
      @user = Factory(:user)
      activate_authlogic
      UserSession.create @user

      @params = {:step => "1",
        :environment => {:name => "Faculdade mauricio de nassau",
          :initials => "FMN",
          :courses_attributes => [{:name => "Gestão de TI",
                                   :path => "gestao-de-ti"}],
        :path => "faculdade-mauricio-de-nassau"},
        :locale => "pt-BR"}
    end

    context "at step 1" do
      before do
        post :create, @params
      end

      it "assigns the environment" do
        assigns[:environment].should_not be_nil
        assigns[:environment].should be_valid
        assigns[:step].should == 2
      end
    end

    context "at step 2" do
      before do
        @params[:step] = "2"
        @params[:plan] = "professor_standard"
        post :create, @params
      end

      it "assigns the environment" do
        assigns[:environment].should_not be_nil
        assigns[:environment].should be_valid
        assigns[:step].should == 3
      end

      it "assigns the plan" do
        assigns[:plan].should_not be_nil
      end
    end

    context "at step 3" do

      context "when is valid" do
        before do
          @params[:step] = "3"
          @params[:plan] = "professor_standard"
          post :create, @params
        end

        it "assigns the environment" do
          assigns[:environment].should_not be_nil
          assigns[:environment].should be_valid
          assigns[:step].should == 4
        end

        it "assigns the plan" do
          assigns[:plan].should_not be_nil
        end
      end

      context "when isn't valid" do
        before do
          @params[:step] = "3"
          @params[:plan] = "professor_standard"
          @params[:environment][:name] = ""
          post :create, @params
        end

        it "assigns the environment" do
         assigns[:environment].should_not be_nil
         assigns[:environment].should_not be_valid
         assigns[:step].should == 3
        end

        it "assigns the plan" do
          assigns[:plan].should_not be_nil
        end
      end
    end
    context "at step 4" do
      context "when plain request" do
        before do
          @params[:step] = "4"
          @params[:plan] = "professor_standard"
          @params[:color] = "f56b00"

          post :create, @params
        end

        it "assigns and creates the environment" do
          assigns[:environment].should_not be_nil
          assigns[:environment].should_not be_new_record
        end

        it "assigns and creates the plan" do
          assigns[:plan].should_not be_nil
          assigns[:plan].should be_valid
          assigns[:plan].should_not be_new_record
        end

        it "associates the plan to the course" do
          assigns[:environment].courses.first.plan.should == assigns[:plan]
        end

        it "associates the quota to the course" do
          course = assigns[:environment].courses.first
          course.quota.should_not be_nil
        end

        it "associates the plan with the user" do
          assigns[:plan].user.should == @user
        end

        it "creates the first order" do
          assigns[:plan].invoices.size.should == 1
        end

        it "redirects to confirmation page" do
          should redirect_to(confirm_plan_path(assigns[:plan]))
        end
      end

      context "when AJAX request" do
        before do
          @params[:step] = "4"
          @params[:plan] = "professor_standard"
          @params[:color] = "f56b00"
          @params[:body] = "js"

          post :create, @params
        end

        it "assigns and creates the environment" do
          assigns[:environment].should_not be_nil
          assigns[:environment].should_not be_new_record
        end

        it "assigns and creates the plan" do
          assigns[:plan].should_not be_nil
          assigns[:plan].should be_valid
          assigns[:plan].should_not be_new_record
        end

        it "associates the plan to the course" do
          assigns[:environment].courses.first.plan.should == assigns[:plan]
        end

        it "associates the quota to the course" do
          course = assigns[:environment].courses.first
          course.quota.should_not be_nil
        end

        it "associates the plan with the user" do
          assigns[:plan].user.should == @user
        end

        it "creates the first order" do
          assigns[:plan].invoices.size.should == 1
        end

      end
    end

    context "at step 4 for free" do
      before do
        @params[:step] = "4"
        @params[:plan] = "free"
        @params[:color] = "f56b00"
        @params[:locale] = "pt-BR"
        @params[:format] = "js"

        post :create, @params
      end

      it "redirects to course page" do
        response.should render_template "environments/redirect"
      end
    end
  end

  context "GET users" do
    before do
      environment = Factory(:environment, :published => true)
      course = Factory(:course, :environment => environment)
      user = Factory(:user)
      course.join user
      activate_authlogic
      UserSession.create user

      get :users, :id => environment.path, :locale => "pt-BR"
    end

    [:users, :teachers, :tutors, :students].each do |v|
      it "assigns #{v}" do
        assigns[v].should_not be_nil
      end
    end
  end
end

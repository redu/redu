require 'spec_helper'
require 'authlogic/test_case'

describe EnvironmentsController do
  context "when creating a paid Environment" do
    before do
      @user = Factory(:user)
      activate_authlogic
      UserSession.create @user

      @params = {:step => 1, :locale => "pt-BR",
        :environment => {:name => "Faculdade mauricio de nassau",
          :courses_attributes => [{:name => "Gestão de TI",
                                   :path => "gestao-de-ti"}],
        :path => "faculdade-mauricio-de-nassau"}}
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
        @params[:step] = 2
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
      before do
        @params[:step] = 3
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

    context "at step 3 for free" do
      before do
        @params[:step] = 3
        @params[:plan] = "free"
        @params[:color] = "f56b00"

        post :create, @params
      end

      it "redirects to course page" do
        should redirect_to(environment_course_path(
          assigns[:environment], assigns[:environment].courses.first))
      end
    end
  end

end

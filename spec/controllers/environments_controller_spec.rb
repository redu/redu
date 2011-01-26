require 'spec_helper'
require 'authlogic/test_case'

describe EnvironmentsController do
  context "when creating an Environment" do
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
        assigns[:plan].should be_valid
      end
    end

    context "at step 3" do
      before do
        @params[:step] = 3
        @params[:plan] = "professor_standard"
        @params[:color] = "f56b00"

        post :create, @params
      end

      xit "assigns the environment" do
        assigns[:environment].should_not be_nil
      end

      xit "assigns the plan" do
        assigns[:plan].should_not be_nil
        assigns[:plan].should be_valid
      end

      xit "associates the plan to the course" do
        assigns[:environment].should_not be_new_record
        assigns[:plan].should_not be_new_record

        assigns[:environment].course.plan.should == assigns[:plan]
      end
    end
  
  end

end

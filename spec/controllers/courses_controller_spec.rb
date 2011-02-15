require 'spec_helper'
require 'authlogic/test_case'

describe CoursesController do
  context "when creating a course for an existing environment" do
    before do
      @user = Factory(:user)
      activate_authlogic
      UserSession.create @user

      @environment = Factory(:environment, :owner => @user)

      @params = {:course =>
        { :name => "Redu", :workload => 12,
          :tag_list => "minhas, tags, exemplo, aula, teste",
          :path => "redu", :subscription_type => 1,
          :description => "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation
        ullamco laboris nisi ut aliquip ex ea commodo."},
      :plan => "free",
      :environment_id => @environment.id,
      :locale => "pt-BR" }
    end

    context "POST create" do
      before do
        post :create, @params
      end

      it "should create the course" do
        assigns[:course].should_not be_nil
        assigns[:course].should be_valid
      end

      it "should create the plan" do
        assigns[:course].plan.should_not be_nil
      end

      it "should assign the plan user to current_user" do
        assigns[:course].plan.user.should == @user
      end

      it "should create the quota and computes it" do
        assigns[:course].quota.should_not be_nil
      end
    end
  end
end

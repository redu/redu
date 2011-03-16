require 'spec_helper'
require 'authlogic/test_case'

describe PlansController do
  context "for Course" do
    before do
      @plan = Factory(:plan)
    end

    context "when GET confirm" do
      before do
        activate_authlogic
        UserSession.create @plan.user
        get :confirm, :id => @plan.id, :locale => "pt-BR"
      end

      it "should load a plan" do
        assigns[:plan].should_not be_nil
        assigns[:plan].should == @plan
      end

      it "should generate an order" do
        assigns[:order].should_not be_nil
        assigns[:order].products.size == @plan.invoices.pending.count
      end
    end
  end

  context "for User" do
    before do
      @user = Factory(:user)
      @course = Factory(:course, :owner => @user)
      @plan = Factory(:plan, :user => @user, :billable => @course)

      activate_authlogic
      UserSession.create @user
    end

    context "when GET index" do
      before do
        get :index, :user_id => @user.id, :locale => "pt-BR"
      end

      it "should assign plans" do
        assigns[:plans].should_not be_nil
        assigns[:plans].should include(@plan)
      end

      it "renders the correct template" do
        response.should render_template('plans/new/index')
      end
    end
  end
end

require 'spec_helper'
require 'authlogic/test_case'

describe PlansController do
  context "for User" do
    before do
      @user = Factory(:user)
      @course = Factory(:course, :owner => @user)
      @plan = Factory(:plan, :user => @user, :billable => @course)
      @plan_not_in_use = Factory(:plan, :user => @user, :billable => @course,
                                 :current => false)

      login_as @user
    end

    context "when GET index" do
      before do
        get :index, :user_id => @user.login, :locale => "pt-BR"
      end

      it "should assign plans" do
        assigns[:plans].should_not be_nil
        assigns[:plans].should include(@plan)
        assigns[:plans].should_not include(@plan_not_in_use)
      end

      it "renders the correct template" do
        response.should render_template('plans/index')
      end
    end
  end

  context "when seeing plan upgrade/downgrade option" do
    context "as a User" do
      before do
        @plan = Factory(:plan)

        login_as @plan.user
        get :options, :id => @plan.id, :locale => "pt-BR"
      end

      it "assigns plan" do
        assigns[:plan].should_not be_nil
        assigns[:plan].should be_kind_of(Plan)
      end

      it "assigns billable_url" do
        assigns[:billable_url].should_not be_nil
        assigns[:billable_url].should =~ /#{@plan.billable.path}/
      end

      it "renders options" do
        response.should render_template('plans/options')
      end
    end

    context "as a partner" do
      before do
        @admin = Factory(:user)
        @partner_assoc = Factory(:partner_environment_association)
        @partner_assoc.partner.add_collaborator @admin
        @plan = Factory(:plan, :billable => @partner_assoc.environment)

        login_as @admin
        get :options, :locale => "pt-BR", :partner_id => @partner_assoc.partner.id,
          :client_id => @partner_assoc.id, :id => @plan.id
      end

      it "assigns partner" do
        assigns[:partner].should == @partner_assoc.partner
      end

      it "assigns client" do
        assigns[:client].should == @partner_assoc
      end

      it "renders partner_environment_associations plans options" do
        response.should render_template("partner_environment_associations/plans/options")
      end
    end
  end

  context "when requesting an upgrade" do
    before do
      @course = Factory(:course)
      @environment = @course.environment
    end

    context "when a billable is a course" do
      before do
        @course.plan = Factory.build(:active_package_plan)
        @plan = @course.plan

        login_as @plan.user

        @params = {
          :environment_id => @environment.path,
          :course_id => @course.path,
          :new_plan => "professor_plus",
          :locale => "pt-BR"
        }
        post :create, @params
      end

      it "assigns course's plan" do
        assigns[:plan].should_not be_nil
        assigns[:plan].should == @plan
      end

      it "assigns new_plan" do
        assigns[:new_plan].should_not be_nil
        assigns[:plan].should be_kind_of(Plan)
      end

      it "assigns a new valid plan" do
        assigns[:new_plan].should be_valid
      end

      it "assigns the correct plan" do
        plan = Plan.from_preset(@params[:new_plan].to_sym)
        assigns[:new_plan].name.should == plan.name
      end

      it "should associates a new plan to course" do
        @course.plan.should_not == @plan
        @course.plan.should == assigns[:new_plan]
      end

      it { should set_the_flash.to("O novo plano foi assinado, você pode ver a fatura abaixo.")}

      it "should redirect to new plan invoices index" do
        response.should redirect_to(plan_invoices_path(assigns[:new_plan]))
      end
    end

    context "when a billable is a environment" do
      before do
        @environment.plan = Factory.build(:active_package_plan)
        @plan = @environment.plan

        login_as @plan.user

        @params = {
          :environment_id => @environment.path,
          :new_plan => "professor_plus",
          :locale => "pt-BR"
        }
        post :create, @params
      end

      it "assigns environment's plan" do
        assigns[:plan].should_not be_nil
        assigns[:plan].should == @plan
      end

      it "assigns new_plan" do
        assigns[:new_plan].should_not be_nil
      end

      it "assigns a new valid plan" do
        assigns[:new_plan].should be_valid
      end

      it "assigns the correct plan" do
        plan = Plan.from_preset(@params[:new_plan].to_sym)
        assigns[:new_plan].name.should == plan.name
      end

      it "should associates a new plan to course" do
        @environment.plan.should_not == @plan
        @environment.plan.should == assigns[:new_plan]
      end

      it { should set_the_flash.to("O novo plano foi assinado, você pode ver a fatura abaixo.")}

      it "should redirect to new plan invoices index" do
        response.should redirect_to(plan_invoices_path(assigns[:new_plan]))
      end
    end

    context "as a partner" do
      before do
        @admin = Factory(:user)
        @partner_assoc = Factory(:partner_environment_association,
                                 :environment => @environment)
        @partner_assoc.partner.add_collaborator @admin
        @plan = Factory(:plan, :billable => @partner_assoc.environment)

        login_as @admin

        @params = {
          :partner_id => @partner_assoc.partner.id,
          :client_id => @partner_assoc.id,
          :environment_id => @environment.path,
          :new_plan => "instituicao_medio",
          :type => "LicensedPlan",
          :locale => "pt-BR"
        }
        post :create, @params
      end

      it "assigns partner" do
        assigns[:partner].should == @partner_assoc.partner
      end

      it "assigns client" do
        assigns[:client].should == @partner_assoc
      end

      it "renders partner_environment_associations plans options" do
        response.should redirect_to partner_client_plan_invoices_path(
          @partner_assoc.partner, @partner_assoc, assigns[:new_plan])
      end

      it "creates the correct plan" do
        assigns[:new_plan].name.should ==
          LicensedPlan::PLANS[@params[:new_plan].to_sym][:name]
      end
    end
  end
end

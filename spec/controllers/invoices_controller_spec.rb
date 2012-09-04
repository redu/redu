require 'spec_helper'
require 'authlogic/test_case'

describe InvoicesController do
  include Authlogic::TestCase

  subject { Factory(:package_invoice) }

  context "when PackageInvoice" do
    before do
      @plan = Factory(:active_package_plan)
      @invoices = []


      @invoices = 3.times.inject([]) do |result, i|
        period_start = Date.today.advance(:days => (i+1) * -30)
        period_end = period_start.advance(:days => 30)

        invoice = Factory(:package_invoice,
                          :plan => @plan,
                          :period_start => period_start,
                          :period_end => period_end)
        invoice.pend!
        result << invoice
      end

      activate_authlogic
      UserSession.create @plan.user
    end

    context "when GET index" do
      it "shold load the invoices correctly" do
        get :index, :plan_id => @plan.id, :locale => "pt-BR"

        assigns[:invoices].should_not be_nil
        Set.new(assigns[:invoices]).should == Set.new(@invoices)
      end

      it "should load the pending invoices" do
        @plan.invoices.first.pay!

        get :index, :plan_id => @plan.id, :locale => "pt-BR", :pending => true

        assigns[:invoices].should_not be_empty
        assigns[:invoices].each do |i|
          i.should be_pending
        end
      end
    end
  end

  context "when LicensedInvoice" do
    context "when viewing a licensed invoice" do
      before do
        @plan = Factory(:active_licensed_plan)

        @invoices = (1..5).collect do |i|
          period_start = Date.new(2011, 01, 01).advance(:days => (i+1) * 30)
          period_end = period_start.advance(:days => 30)


          invoice = Factory(:licensed_invoice,
                            :plan => @plan,
                            :period_start => period_start,
                            :period_end => period_end)
          (1..5).each { Factory(:license, :invoice => invoice) }
          invoice.pend!
          invoice
        end

        activate_authlogic
        UserSession.create @plan.billable.owner
        get :show, :plan_id => @plan.id, :id => @invoices.first.id,
          :locale => "pt-BR"
      end

      it "should assign licensed invoice" do
        assigns[:plan].should_not be_nil
      end

      it "should assign licensed invoice" do
        assigns[:invoice].should_not be_nil
      end
    end

    context "when involving partner" do
      before do
        User.maintain_sessions = false
        @user = Factory(:user)
        activate_authlogic
        UserSession.create @user

        @partner = Factory(:partner)
        @environments = 3.times.collect do
          Factory(:partner_environment_association, :partner => @partner).
            environment
        end
        @partner.add_collaborator(@user)

        plan = Plan.from_preset(:instituicao_superior, "LicensedPlan")
        plan.user = @environments[0].owner
        @environments[0].plan = plan

        plan = Plan.from_preset(:curso_extensao, "LicensedPlan")
        plan.user = @environments[1].owner
        @environments[1].plan = plan

        plan = Plan.from_preset(:curso_corporativo, "LicensedPlan")
        plan.user = @environments[2].owner
        @environments[2].plan = plan
      end

      context "when viewing invoices of a partner" do
        before do
          @environments[0].plan.create_invoice({
            :invoice => {
            :period_start =>  Date.new(2011, 03, 15),
            :period_end => Date.new(2011, 03, 15).end_of_month,
          }
          })
          @environments[1].plan.create_invoice({
            :invoice => {
            :period_start =>  Date.new(2010, 12, 10),
            :period_end => Date.new(2010, 12, 10).end_of_month,
          }
          })
          @environments[2].plan.create_invoice({
            :invoice => {
            :period_start =>  Date.new(2011, 04, 15),
            :period_end => Date.new(2011, 04, 15).end_of_month,
          }
          })

          Date.stub(:today) { Date.new(2010, 12, 01) }
          LicensedInvoice.refresh_states!
          Date.stub(:today) { Date.new(2011, 01, 01) }
          LicensedInvoice.refresh_states!
          Date.stub(:today) { Date.new(2011, 02, 01) }
          LicensedInvoice.refresh_states!
          Date.stub(:today) { Date.new(2011, 03, 01) }
          LicensedInvoice.refresh_states!
          Date.stub(:today) { Date.new(2011, 04, 01) }
          LicensedInvoice.refresh_states!
          Date.stub(:today) { Date.new(2011, 05, 01) }
          LicensedInvoice.refresh_states!
        end

        context "with no period set" do
          before do
            get :index, :partner_id => @partner.id, :locale => "pt-BR"
          end

          it "assigns partner" do
            assigns[:partner].should_not be_nil
          end

          it "assigns all invoices" do
            assigns[:invoices].should_not be_nil
            assigns[:invoices].length.should == 11
          end

          it "renders partners/invoices/monthly" do
            response.should render_template("partners/invoices/monthly")
          end
        end

        context "with year set" do
          before do
            get :index, :partner_id => @partner.id, :year => "2011",
              :locale => "pt-BR"
          end

          it "assigns all invoices of the requested period" do
            assigns[:invoices].should_not be_nil
            assigns[:invoices].length.should == 10
          end

          it "renders partners/invoices/index" do
            response.should render_template("partners/invoices/index")
          end
        end

        context "with year and month set" do
          before do
            get :index, :partner_id => @partner.id, :year => "2011",
              :month => "4", :locale => "pt-BR"
          end

          it "assigns all invoices of the requested period" do
            assigns[:invoices].should_not be_nil
            assigns[:invoices].length.should == 3
          end

          it "renders partners/invoices/index" do
            response.should render_template("partners/invoices/index")
          end
        end
      end

      context "when viewing invoices of a partner client" do
        before do
          @environment = @environments[0]
          get :index, :partner_id => @partner.id, :plan_id => @environment.plan.id,
            :client_id => @environment.
            partner_environment_association.id, :locale => "pt-BR"
        end

        it "assigns partner" do
          assigns[:partner].should_not be_nil
          :w
        end

        it "assigns client" do
          assigns[:client].should_not be_nil
        end

        it "renders partner_environment_associations/invoices/index" do
          response.should render_template("partner_environment_associations/" \
                                          "invoices/index")
        end
      end


      context "when paying an invoice" do
        before do
          activate_authlogic
          UserSession.create Factory(:user, :role => Role[:admin])

          @invoice = @environments[0].plan.create_invoice
          @invoice.update_attribute(:state, "pending")

          post :pay, :id => @invoice.id, :plan_id => @invoice.plan.id,
            :locale => "pt-BR"
        end

        it "assigns an invoice" do
          assigns[:invoice].should_not be_nil
        end

        it "should call pay!" do
          @invoice.reload.should be_paid
        end

        it "redirects to Invoices#index" do
          response.should redirect_to(plan_invoices_path(@invoice.plan))
        end
      end
    end
  end
end

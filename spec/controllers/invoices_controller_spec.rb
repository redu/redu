require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe InvoicesController do
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
    before do
      @plan = Factory(:active_licensed_plan)

      @invoices = (1..5).collect do |i|
        period_start = Date.new(2011, 01, 01).advance(:days => (i+1) * 30)
        period_end = period_start.advance(:days => 30)


        invoice = Factory(:licensed_invoice,
                          :plan => @plan,
                          :period_start => period_start,
                          :period_end => period_end)
        invoice.pend!
        invoice
      end

      activate_authlogic
      UserSession.create @plan.billable.owner
    end

    context "when viewing a licensed invoice" do
      before do
        get :show, :plan_id => @plan.id, :id => @invoices.first.id,
          :locale => "pt-BR"
      end

      it "should assign licensed invoice" do
        assigns[:invoice].should_not be_nil
      end

      it "should assign partner" do
        assigns[:partner].should_not be_nil
      end
    end
  end
end

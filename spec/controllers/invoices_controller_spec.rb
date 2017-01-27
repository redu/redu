# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'authlogic/test_case'

describe InvoicesController do
  subject { FactoryGirl.create(:package_invoice) }

  context "when PackageInvoice" do
    before do
      @plan = FactoryGirl.create(:active_package_plan)
      @invoices = []


      @invoices = 3.times.inject([]) do |result, i|
        period_start = Date.today.advance(:days => (i+1) * -30)
        period_end = period_start.advance(:days => 30)

        invoice = FactoryGirl.create(:package_invoice,
                          :plan => @plan,
                          :period_start => period_start,
                          :period_end => period_end)
        invoice.pend!
        result << invoice
      end

      login_as @plan.user
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
        @plan = FactoryGirl.create(:active_licensed_plan)

        @invoices = (1..5).collect do |i|
          period_start = Date.new(2011, 01, 01).advance(:days => (i+1) * 30)
          period_end = period_start.advance(:days => 30)


          invoice = FactoryGirl.create(:licensed_invoice,
                            :plan => @plan,
                            :period_start => period_start,
                            :period_end => period_end)
          (1..5).each { FactoryGirl.create(:license, :invoice => invoice) }
          invoice.pend!
          invoice
        end

        login_as @plan.billable.owner
        get :show, :plan_id => @plan.id, :id => @invoices.first.id,
          :locale => "pt-BR"
      end

      it "should assign plan" do
        assigns[:plan].should_not be_nil
      end

      it "should assign licensed invoice" do
        assigns[:invoice].should_not be_nil
      end
    end
  end
end

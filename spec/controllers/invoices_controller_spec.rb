require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe InvoicesController do
  before do
    @plan = Factory(:plan)
    @invoices = []


    @invoices = 3.times.inject([]) do |result, i|
      period_start = Date.today.advance(:days => (i+1) * -30)
      period_end = period_start.advance(:days => 30)

      invoice = Factory(:invoice,
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

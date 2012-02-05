require 'spec_helper'

describe LicensedPlan do
  subject { Factory(:active_licensed_plan) }

  it "should have a infinity members limit" do
    infinity = 1.0/0
    subject.members_limit.should == infinity
  end

  it { should respond_to :create_invoice }

  context "when creating invoices" do
    before do
      subject.create_invoice
      @invoice = subject.invoices.last
    end

    it "should be valid" do
      @invoice.should be_valid
    end

    it "should defaults to open" do
      @invoice.should be_open
    end

    it "should initiates period today" do
      @invoice.period_start.should == Date.today
    end

    it "should ends period on the end of month" do
      @invoice.period_end.should == Date.today.end_of_month
    end

    it "should initiates without amount" do
      @invoice.amount.should be_nil
    end

    context "when passing attributes" do
      before do
        @from = Date.today + 20.days
        subject.create_invoice({:invoice => {
          :period_start => @from,
          :period_end => @from.end_of_month,
          :amount => 10.00} })
        @invoice = subject.invoices.last
      end

      it "should have correct attributes" do
        @invoice.period_start.should == @from
        @invoice.period_end.should == @from.end_of_month
      end

      it "should not accept amount value" do
        @invoice.amount.should be_nil
      end
    end
  end

  context "when setting up the plan"


  context "when creating a new order"
end

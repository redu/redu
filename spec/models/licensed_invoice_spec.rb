require 'spec_helper'

describe LicensedInvoice do
  subject { Factory(:licensed_invoice) }

  it { should belong_to :plan }
  it { should have_many :licenses }
  it { should validate_presence_of :period_start }
  it { should respond_to :generate_description }

  context "when having state machine" do
    it "should defaults to open" do
      should be_open
    end

    [:state, :pend!, :pay!].each do |attr|
      it "should respond_to #{attr}" do
        should respond_to attr
      end
    end

    context "when open" do
      it "should change to pending" do
        subject.pend!
        should be_pending
      end
    end

    context "when pending" do
      before do
        subject.update_attribute(:state, "pending")
      end

      it "should change to paid" do
        subject.pay!
        should be_paid
      end
    end
  end

  context "description" do
    before do
      @plan = Plan.from_preset(PackagePlan::PLANS[:empresa_plus], "PackagePlan")
      subject.plan = @plan
      subject.save
      subject.reload
    end

    it "should generate something" do
      subject.generate_description.should_not be_nil
      subject.generate_description.should_not be_empty
    end
  end

  context "retrivers" do
    it "should retrieve all licensed invoices within certain month and year" do
      os1 = Factory(:licensed_invoice, :period_start => "2011-10-01", :period_end => "2011-10-31")
      os2 = Factory(:licensed_invoice, :period_start => "2011-12-01", :period_end => "2011-12-31")
      os3 = Factory(:licensed_invoice, :period_start => "2012-01-01", :period_end => "2012-01-15")
      os4 = Factory(:licensed_invoice, :period_start => "2012-01-16", :period_end => "2012-01-31")

      LicensedInvoice.retrieve_by_month_year(1, 2012).to_set.should == [os3, os4].to_set
    end

    it "should retrieve actual licensed invoice" do
      os1 = Factory(:licensed_invoice, :period_start => "2011-12-01", :period_end => "2011-12-31")
      os2 = Factory(:licensed_invoice, :period_start => "2012-01-01", :period_end => "2012-01-15")
      os3 = Factory(:licensed_invoice, :period_start => "2012-01-16", :period_end => "2012-01-31")

      LicensedInvoice.actual.should == [os3]
    end
  end

  it "LicensedPlan should respond to refresh_amounts!" do
    LicensedInvoice.respond_to?(:refresh_amounts!).should be_true
  end

  context "when generating the amount" do
    before do
      plan = Factory(:active_licensed_plan, :price => 3.00)

      from = Date.new(2010, 01, 15)
      plan.create_invoice({:invoice => {
        :period_start => from,
        :period_end => from.end_of_month} })
        @invoice1 = plan.invoices.last

      from = Date.today
      plan.create_invoice({:invoice => {
        :period_start => from,
        :period_end => from.end_of_month} })

      @invoice2 = plan.invoices.last
      (1..20).collect { Factory(:license, :invoice => @invoice1) }
      (1..20).collect { Factory(:license, :invoice => @invoice2) }


      LicensedInvoice.refresh_amounts!
      @invoice1.reload
      @invoice2.reload
    end

    it "should change invoice1 to be pending" do
      @invoice1.should be_pending
    end

    it "should maintain invoice2 as open" do
      @invoice2.should be_open
    end

    it "should calculates invoice1's relative amount" do
      @invoice1.reload.amount.round(2).should == BigDecimal.new("30.97")
    end

    it "should NOT calculate invoice2's relative amount" do
      @invoice2.amount.should be_nil
    end
  end
end

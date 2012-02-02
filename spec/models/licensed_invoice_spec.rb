require 'spec_helper'

describe LicensedInvoice do
  subject { Factory(:licensed_invoice) }

  it { should belong_to :original_partner_plan }
  it { should belong_to :partner_plan }
  it { should have_many :licenses}
  it { should validate_presence_of :period_start }
  it { should respond_to :generate_descritption }

  context "description" do
    before do
      @plan = Plan.from_preset(PartnerPlan::PLANS[:empresa_plus], "PartnerPlan")
      subject.partner_plan = @plan
      subject.save
      subject.reload
    end

    it "should generate something" do
      subject.generate_descritption.should_not be_nil
      subject.generate_descritption.should_not be_empty
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

  context "when been cloned to another plan" do
    it "should make the clone has the correct original partner plan"
  end
end

# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'set'

describe Invoice do
  subject { FactoryGirl.create(:invoice) }

  it { should belong_to(:plan) }
  [:period_start, :period_end].each do |attr|
    it { should validate_presence_of attr }
  end
  it { should respond_to :previous_balance }
  it { should_not allow_mass_assignment_of :state }

  context "finder" do
    it "retrieves pending invoices" do
      plan = FactoryGirl.create(:plan)
      pending_invoices = (1..5).collect { FactoryGirl.create(:invoice,
                                                  :plan => plan,
                                                  :state => "pending") }
      overdue_invoices = (1..5).collect { FactoryGirl.create(:invoice,
                                                  :plan => plan,
                                                  :state => "overdue") }

      plan.invoices.pending.to_set == pending_invoices.to_set
    end

    it "retrieves invoices of a period" do
      april_invoices = (1..5).collect do
        period_start = Date.new(2011, 04, 10)
        FactoryGirl.create(:invoice, :period_start => period_start,
                :period_end => period_start.end_of_month)
      end

      feb_invoices = (1..5).collect do
        period_start = Date.new(2011, 02, 10)
        FactoryGirl.create(:invoice, :period_start => period_start,
                :period_end => period_start.end_of_month)
      end

      last_year_invoices = (1..5).collect do
        period_start = Date.new(2010, 04, 10)
        FactoryGirl.create(:invoice, :period_start => period_start,
                :period_end => period_start.end_of_month)
      end

      april_period = Date.new(2011, 04)..Date.new(2011, 04).end_of_month
      Invoice.of_period(april_period).to_set.
        should == april_invoices.to_set

      last_year_period = Date.new(2010)..Date.new(2010).end_of_year
      Invoice.of_period(last_year_period).to_set.
        should == last_year_invoices.to_set
    end

    it "retrieves invoices of a billable" do
      plans = 2.times.collect do
        FactoryGirl.create(:plan, :billable => FactoryGirl.create(:environment))
      end
      invoices = 3.times.collect do
        FactoryGirl.create(:invoice, :plan => plans[0])
      end
      other_invoices = 3.times.collect do
        FactoryGirl.create(:invoice, :plan => plans[1])
      end

      Invoice.of_billable(plans[0].billable, plans[0].billable.class).to_set.
        should == invoices.to_set
    end
  end

  it "should return the total value" do
    subject.update_attributes(:amount => BigDecimal.new("45"),
                              :previous_balance => 10)
    subject.total.should == BigDecimal.new("55")
  end

  it "should return the total of days" do
    subject.period_start = Date.today
    subject.period_end = Date.today + 15.days
    subject.total_days.should == 16
  end

  context "when verifying if the next invoice can be created" do
    context "when the period_end has finished" do
      before do
        subject.update_attribute(:period_end, Date.today - 3.days)
      end

      it "can create next invoice" do
        subject.can_create_next_invoice?.should be_true
      end
    end

   context "when the period_end has not finished" do
      before do
        subject.update_attribute(:period_end, Date.today + 3.days)
      end

      it "can NOT create next invoice" do
        subject.can_create_next_invoice?.should be_false
      end
   end

    context "when the billable has been removed" do
      before do
        subject.plan.billable.destroy
      end

      it "can NOT create next invoice" do
        subject.can_create_next_invoice?.should be_false
      end
    end

    context "when the billable has not been removed" do
      before do
        subject.update_attribute(:period_end, Date.today - 3.days)
        subject.plan.billable = FactoryGirl.create(:environment)
      end

      it "can create next invoice" do
        subject.can_create_next_invoice?.should be_true
      end
    end
  end
end

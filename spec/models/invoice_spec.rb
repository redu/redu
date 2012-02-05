require 'spec_helper'
require 'set'

describe Invoice do
  subject { Factory(:invoice) }

  it { should belong_to(:plan) }
  [:period_start, :period_end].each do |attr|
    it { should validate_presence_of attr }
  end
  it { should_not allow_mass_assignment_of :state }

  context "finder" do
    it "retrieves pending invoices" do
      plan = Factory :plan
      pending_invoices = (1..5).collect { Factory(:invoice,
                                                  :plan => plan,
                                                  :state => "pending") }
      overdue_invoices = (1..5).collect { Factory(:invoice,
                                                  :plan => plan,
                                                  :state => "overdue") }

      plan.invoices.pending.to_set == pending_invoices.to_set
    end
  end

end

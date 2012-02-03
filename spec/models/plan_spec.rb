require 'spec_helper'

describe Plan do
  subject { Factory(:plan) }

  it { should belong_to :billable }
  it { should belong_to :user }
  it { should have_many :invoices }
  it { should_not allow_mass_assignment_of :state }
  it { should validate_presence_of :price }

  def period
    (Date.today.at_end_of_month - Date.today).to_i
  end

  context "states" do
    [:block!, :migrate!, :activate!, :state].each do |attr|
      it "responds to" do
        should respond_to attr
      end
    end

    it "defaults to active" do
      subject.state.should == "active"
    end

    it "shoould reactivate withdout error" do
      expect {
        subject.activate!
      }.should_not change { subject.state }
    end

    it "blocks" do
      expect {
        subject.block!
      }.should change { subject.state }.to "blocked"
    end

    it "migrates" do
      expect {
        subject.migrate!
      }.should change { subject.state }.to "migrated"
    end

    it "activates" do
      subject.block!

      expect {
        subject.activate!
      }.should change(subject, :state).from("blocked").to("active")

    end
  end

  context "when migrating to a new plan" do
    before do
      @amount_per_day = subject.price / subject.days_in_current_month
      subject.create_invoice(:package_invoice => {
        :period_start => Date.new(2011, 01, 01),
        :period_end => Date.new(2011, 01, 31),
        :amount =>  31 * @amount_per_day})

      subject.create_invoice(:package_invoice => {
        :period_start => Date.new(2011, 02, 01),
        :period_end => Date.new(2011, 02, 28),
        :amount =>  28 * @amount_per_day})

      @new_plan = subject.migrate_to(:name => "Novo plano",
                                     :members_limit => 30,
                                     :price => 10,
                                     :yearly_price => 100)
    end

    xit "responds to migrate_to" do
      should respond_to :migrate_to
    end

    xit "sets state to migrated" do
      subject.state.should == "migrated"
    end

    xit "creates a valid and new plan" do
      @new_plan.should be_valid
    end

    xit "copies the older plan associations" do
      @new_plan.user.should == subject.user
      @new_plan.billable.should == subject.billable
    end

    xit "preserves the original invoices" do
      subject.invoices.to_set.should be_subset(@new_plan.invoices.to_set)
    end
  end

  context "when upgrading" do
    before do
      # Garantindo que o plano atual é inferior ao próximo
      subject { Factory(:plan, :price => 50, :yearly_price => 150) }

      @amount_per_day = subject.price / subject.days_in_current_month
      subject.create_invoice(:package_invoice => {
        :period_start => Date.new(2011, 01, 01),
        :period_end => Date.new(2011, 01, 31),
        :amount =>  31 * @amount_per_day})

      subject.create_invoice(:package_invoice => {
        :period_start => Date.new(2011, 02, 01),
        :period_end => Date.new(2011, 02, 28),
        :amount =>  28 * @amount_per_day})

      subject.invoices.pending.map { |i| i.pay! }
      subject.invoices.reload

      @new_plan = subject.migrate_to(:name => "Novo plano",
                                     :members_limit => 30,
                                     :price => 10,
                                     :yearly_price => 100)

    end

    xit "creates an additional invoice on the new plan" do

      invoice = @new_plan.invoices.pending.first(:conditions => {
        :period_start => Date.tomorrow,
        :period_end => Date.today.advance(:days => 30)})

      invoice.should_not be_nil
    end

    xit "gives a discount on the first invoice of the new plan" do
      per_day = subject.price / subject.days_in_current_month
      discount = period * per_day

      invoice = @new_plan.invoices.pending.first

      invoice.amount.round(2).should == @new_plan.price - discount
    end

  end



  context "when creating a preset" do
    it "should respond to from_preset" do
      Plan.should respond_to(:from_preset)
    end

    it "creates a plan from preset" do
      plan = Plan.from_preset(:professor_standard)
      plan.should be_valid
    end
  end

  context "when pending payment" do
    before do
      invoices = 3.times.inject([]) do |res,i|
        invoice = Factory(:package_invoice, :plan => subject)
        invoice.pend!
        res << invoice
      end
    end

    it "responds to pending_payment?" do
      subject.should respond_to(:pending_payment?)
    end

    it "returns true if there are pending invoices" do
      subject.pending_payment?.should be_true
    end

  end

  context "when overdue payment" do
    before  do
      invoices = 3.times.inject([]) do |acc,i|
        invoice = Factory(:package_invoice, :plan => subject)
        invoice.overdue!
        acc << invoice
      end
    end

    it "returns true if there are overdue invoices" do
      subject.pending_payment?.should be_true
    end
  end

  context "when pre setting a package plan" do
    before do
      @plan = Plan.from_preset(:professor_lite, "PackagePlan")
    end

    it "should initialize a valid plan" do
      @plan.should be_valid
    end

    it "should have the correct informations" do
      @plan.name.should == PackagePlan::PLANS[:professor_lite][:name]
    end

    it "should be a PartnerPlan" do
      @plan.is_a?(PackagePlan).should be_true
    end

    context "when trying to preset a inexistent type of plan" do
      before do
        @another_plan = Plan.from_preset(:professor_lite, "CoolPlan")
      end

      it "should return a plan with type PackagePlan" do
        @another_plan.class.should == PackagePlan
      end
    end

    context "when trying to preset a inexistent plan" do
      before do
        @another_plan = Plan.from_preset(:inexistent)
      end

      it "should return a plan with correct name" do
        @another_plan.name.should == PackagePlan::PLANS[:free][:name]
      end
    end
  end
end

require 'spec_helper'

describe Plan do
  before do
    UserNotifier.delivery_method = :test
    UserNotifier.perform_deliveries = true
  end

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

    it "sends an email when blocked" do
      expect {
        subject.block!
      }.should change {UserNotifier.deliveries.size }.by(1)
      UserNotifier.deliveries.last.body.should =~ /foi bloqueado/
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

      it "should return a plan with correct name in this case" do
        @another_plan.name.should == PackagePlan::PLANS[:professor_lite][:name]
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

  context "when billable is destroyed" do
    before do
      subject.billable.audit_billable_and_destroy
      subject.reload
    end

    it "sends email when blocked" do
      expect {
        subject.block!
      }.should change(UserNotifier.deliveries, :count).by(1)
    end
  end
end

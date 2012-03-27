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

    it "sends an email when blocked" do
      UserNotifier.delivery_method = :test
      UserNotifier.perform_deliveries = true
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

  context "when dealing with current invoice" do
    before do
      subject.invoices = []
    end

    it { should respond_to(:invoice) }
    it { should respond_to(:invoice=) }

    it "should retrieve the current invoice" do
      invoice1 = Factory(:invoice, :plan => subject, :current => false)
      invoice2 = Factory(:invoice, :plan => subject)
      subject.reload

      subject.invoice.should == invoice2
    end

    it "should store the invoice as current" do
      invoices = (1..2).collect do
        Factory(:invoice, :plan => subject, :current => false)
      end
      subject.reload

      invoice1 = Factory.build(:invoice)
      subject.invoice = invoice1
      subject.save
      subject.invoice.should == invoice1

      invoice2 = Factory(:invoice)
      subject.invoice = invoice2
      subject.invoice.should == invoice2

      subject.invoices.to_set.should == (invoices << invoice1 << invoice2).to_set
    end

    it "should return nil as current" do
      invoices = (1..2).collect do
        Factory(:invoice, :plan => subject, :current => false)
      end
      subject.reload

      invoice1 = Factory(:invoice)
      subject.invoice = invoice1

      subject.invoice = nil
      subject.invoice.should be_nil
    end
  end

  context "when migrating to another plan" do
    let(:subject) { Factory(:plan, :price => 15.90) }

    context "when upgrading" do
      before do
        subject.invoice = Factory(:package_invoice)
        @billable = subject.billable

        @new_plan = Factory.build(:active_package_plan, :price => 25.40)
      end

      it "should have new plan as current" do
        subject.migrate_to @new_plan
        @billable.plan.should == @new_plan
      end

      it "should creates a new invoice to new plan with correct dates" do
        last_invoice_period_end = subject.invoice.period_end
        expect {
          subject.migrate_to @new_plan
        }.should change(@new_plan.invoices, :count).by(1)
        subject.invoice.period_end.should == Date.yesterday
        @new_plan.invoice.period_start.should == Date.today
        @new_plan.invoice.period_end.should == last_invoice_period_end
      end

      context "when last invoice is open" do
        before do
          subject.update_attribute(:price, 2)
          subject.invoice = Factory(:licensed_invoice, :state => "open",
                                    :previous_balance => -4)
          (1..10).each { Factory(:license, :invoice => subject.invoice)}
        end

        it "should change last invoice to closed" do
          expect {
            subject.migrate_to @new_plan
          }.should change{ subject.invoice.state }.to("closed")
        end

        it "should have an addition on new invoice" do
          subject.migrate_to @new_plan
          @new_plan.invoice.previous_balance.should be > 0
          @new_plan.invoice.previous_balance.should == subject.invoice.total
        end
      end

      context "when last invoice is pending" do
        before do
          subject.invoice = Factory(:package_invoice, :state => "pending",
                                    :amount => 15.9, :previous_balance => 2)
        end

        it "should change last invoice to closed" do
          expect {
            subject.migrate_to @new_plan
          }.should change{ subject.invoice.state }.to("closed")
        end

        it "should have an addition on new invoice" do
          subject.migrate_to @new_plan
          @new_plan.invoice.previous_balance.should be > 0
          @new_plan.invoice.previous_balance.should == subject.invoice.total
        end
      end

      context "when last invoice is paid" do
        before do
          subject.invoice = Factory(:package_invoice, :state => "paid",
                                    :amount => 10, :previous_balance => 3)
        end

        it "should maintain last invoice as paid" do
          expect {
            subject.migrate_to @new_plan
          }.should_not change{ subject.invoice.state }
        end

        it "should have a discount on new invoice" do
          subject.migrate_to @new_plan
          @new_plan.invoice.previous_balance.should be < 0
          @new_plan.invoice.previous_balance.should == - subject.invoice.total
        end
      end
    end

    context "when downgrading" do
      before do
        subject.invoice = Factory(:package_invoice)
        @billable = subject.billable

        @new_plan = Factory.build(:active_package_plan, :price => 10.70)
      end

      context "when last invoice is open and total is less than zero" do
        before do
          subject.update_attribute(:price, 2)
          subject.invoice = Factory(:licensed_invoice, :state => "open",
                                    :previous_balance => -100)
          (1..10).each { Factory(:license, :invoice => subject.invoice)}
          subject.migrate_to @new_plan
        end

        it "should have a discount on new invoice" do
          @new_plan.invoice.previous_balance.should be < 0
          @new_plan.invoice.previous_balance.should == subject.invoice.total
        end
      end

      context "when last invoice is pending and total is less than zero" do
        before do
          subject.invoice = Factory(:package_invoice, :state => "pending",
                                    :previous_balance => -200)
          subject.migrate_to @new_plan
        end

        it "should have a discount on new invoice" do
          @new_plan.invoice.previous_balance.should be < 0
          @new_plan.invoice.previous_balance.should == subject.invoice.total
        end
      end

      context "when last invoice is paid and total is less than zero" do
        before do
          subject.invoice = Factory(:package_invoice, :state => "paid",
                                    :previous_balance => -200)
          subject.migrate_to @new_plan
        end

        it "should have a discount on new invoice" do
          @new_plan.invoice.previous_balance.should be < 0
          @new_plan.invoice.previous_balance.should == subject.invoice.total
        end
      end
    end

    context "when new plan is licensed" do
      before do
        subject.invoice = Factory(:package_invoice)
        subject.billable = Factory(:environment, :owner => subject.user)
        (1..5).collect do
          c = Factory(:course, :environment => subject.billable)
          (1..10).each { c.join Factory(:user) }
        end
        subject.billable.reload

        @new_plan = Factory.build(:active_licensed_plan, :price => 4.5,
                                 :billable => nil)
        subject.migrate_to @new_plan
      end

      it "should create all licenses" do
        users = subject.billable.courses.collect do |c|
          c.approved_users
        end.flatten
        @new_plan.invoice.licenses.should_not be_empty
        @new_plan.invoice.licenses.should have(users.count).items
      end
    end
  end
end

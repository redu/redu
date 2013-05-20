# -*- encoding : utf-8 -*-
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
  it { should_not allow_mass_assignment_of :billable_audit }
  it { should validate_presence_of :price }
  it { should validate_presence_of :user }

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
      }.to_not change { subject.state }
    end

    it "blocks" do
      expect {
        subject.block!
      }.to change { subject.state }.to "blocked"
    end

    it "sends an email when blocked" do
      expect {
        subject.block!
      }.to change {UserNotifier.deliveries.size }.by(1)
      UserNotifier.deliveries.last.body.should =~ /foi bloqueado/
    end

    it "migrates" do
      expect {
        subject.migrate!
      }.to change { subject.state }.to "migrated"
    end

    it "activates" do
      subject.block!

      expect {
        subject.activate!
      }.to change(subject, :state).from("blocked").to("active")
    end
  end

  context "when creating a preset" do
    it "should respond to from_preset" do
      Plan.should respond_to(:from_preset)
    end

    it "creates a plan from preset" do
      plan = Plan.from_preset(:professor_standard)
      plan.user = Factory(:user)
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
      @plan.user = Factory(:user)
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
        subject.invoice = Factory(:package_invoice,
                                  :period_start => Date.today - 15.days,
                                  :period_end => Date.today + 15.days)
        @billable = subject.billable

        @new_plan = Factory.build(:active_package_plan, :price => 25.40)
      end

      it "should change to migrated" do
        expect {
          subject.migrate_to @new_plan
        }.to change{ subject.state }.to("migrated")
      end

      it "should have new plan as current" do
        subject.migrate_to @new_plan
        @billable.plan.should == @new_plan
      end

      it "should associate the new plan with the billable" do
        billable = subject.billable
        subject.migrate_to @new_plan
        @new_plan.billable.should == billable
      end

      it "should associate the new plan with the user" do
        user = subject.user
        subject.migrate_to @new_plan
        @new_plan.user.should == user
      end

      it "should create a new invoice to new plan with correct dates" do
        last_invoice_period_end = subject.invoice.period_end
        expect {
          subject.migrate_to @new_plan
        }.to change(@new_plan.invoices, :count).by(1)
        subject.invoice.period_end.should == Date.yesterday
        @new_plan.invoice.period_start.should == Date.today
        @new_plan.invoice.period_end.should == last_invoice_period_end
      end

      it "should have a invoice with amount value of 13.11" do
        subject.migrate_to @new_plan
        @new_plan.invoice.amount.round(2).should == BigDecimal.new("13.11")
      end

      context "when last invoice is open" do
        before do
          subject.update_attribute(:price, 2)
          subject.invoice = Factory(:licensed_invoice, :state => "open",
                                    :amount => nil,
                                    :previous_balance => -4,
                                    :period_start => Date.today - 15.days,
                                    :period_end => Date.today + 15.days)
          (1..10).each { Factory(:license, :invoice => subject.invoice,
                                 :period_start => Date.today - 15.days,
                                 :period_end => nil)}
        end

        it "should change last invoice to closed" do
          expect {
            subject.migrate_to @new_plan
          }.to change{ subject.invoice.state }.to("closed")
        end

        it "should have an addition on new invoice" do
          subject.migrate_to @new_plan
          @new_plan.invoice.previous_balance.should be > 0
          @new_plan.invoice.previous_balance.should == subject.invoice.total
        end
      end

      context "when last invoice is pending" do
        before do
          # Amount R$ 7.69
          subject.invoice = Factory(:package_invoice, :state => "pending",
                                    :amount => 15.9, :previous_balance => 2,
                                    :period_start => Date.today - 15.days,
                                    :period_end => Date.today + 15.days)
        end

        it "should change last invoice to closed" do
          expect {
            subject.migrate_to @new_plan
          }.to change{ subject.invoice.state }.to("closed")
        end

        it "should have an addition of 9.70 on new invoice" do
          subject.migrate_to @new_plan
          @new_plan.invoice.previous_balance.should be > 0
          @new_plan.invoice.previous_balance.round(2).should ==
            BigDecimal.new("9.69")
        end
      end

      context "when last invoice is paid" do
        before do
          # Amount R$ 4.84
          subject.invoice = Factory(:package_invoice, :state => "paid",
                                    :amount => 10, :previous_balance => 3,
                                    :period_start => Date.today - 15.days,
                                    :period_end => Date.today + 15.days)
        end

        it "should maintain last invoice as paid" do
          expect {
            subject.migrate_to @new_plan
          }.to_not change{ subject.invoice.state }
        end

        it "should have a discount of 5.16 on new invoice" do
          subject.migrate_to @new_plan

          @new_plan.invoice.previous_balance.round(2).should ==
            - BigDecimal.new("5.16")
        end
      end

      context "when does not have any invoices" do
        before do
          subject.invoices = []
          subject.save
        end

        it "should create a new invoice with no discount or addition" do
          subject.migrate_to @new_plan
          @new_plan.invoice.previous_balance.should == 0
          @new_plan.invoice.total.should == @new_plan.price
        end

        it "should create a new invoice with period_end at 30 days from today (package)" do
          subject.migrate_to @new_plan
          @new_plan.invoice.period_end.should == Date.today + 30.days
        end
      end
    end

    context "when downgrading" do
      before do
        # Invoice com 31 dias
        subject.invoice = Factory(:package_invoice,
                                  :amount => 40.55,
                                  :period_start => Date.today - 15.days,
                                  :period_end => Date.today + 15.days)
        @billable = subject.billable

        @new_plan = Factory.build(:active_package_plan, :price => 10.70)
      end

      it "should have an invoice with amount value of 5.52" do
        subject.migrate_to @new_plan
        @new_plan.invoice.amount.round(2).should == BigDecimal.new("5.52")
      end

      context "when last invoice is open and total is less than zero" do
        before do
          subject.update_attribute(:price, 2)
          # Amount R$ 10.00
          subject.invoice = Factory(:licensed_invoice, :state => "open",
                                    :previous_balance => -100,
                                    :period_start => Date.today - 15.days,
                                    :period_end => Date.today + 15.days)
          (1..10).each { Factory(:license, :role => Role[:member],
                                 :invoice => subject.invoice,
                                 :period_start => Date.today - 15.days,
                                 :period_end => nil)}

          subject.migrate_to @new_plan
        end

        it "should have a discount of 90 on new invoice" do
          @new_plan.invoice.previous_balance.round(2).should ==
            - BigDecimal.new("90")
        end
      end

      context "when last invoice is pending and total is less than zero" do
        before do
          # Amount R$ 21.77
          subject.invoice = Factory(:package_invoice, :state => "pending",
                                    :amount => 45,
                                    :previous_balance => -200,
                                    :period_start => Date.today - 15.days,
                                    :period_end => Date.today + 15.days)

          subject.migrate_to @new_plan
        end

        it "should have a discount of 178.23 on new invoice" do
          @new_plan.invoice.previous_balance.round(2).should ==
            - BigDecimal.new("178.23")
        end
      end

      context "when last invoice is paid and total is less than zero" do
        before do
          # Amount 21.77
          subject.invoice = Factory(:package_invoice, :state => "paid",
                                    :amount => 45,
                                    :previous_balance => -200,
                                    :period_start => Date.today - 15.days,
                                    :period_end => Date.today + 15.days)

          subject.migrate_to @new_plan
        end

        it "should have a discount of 155 on new invoice" do
          @new_plan.invoice.previous_balance.round(2).should ==
            - BigDecimal.new("178.23")
        end
      end
    end

    context "when new plan is licensed" do
      before do
        subject.invoice = Factory(:package_invoice,
                                  :period_start => Date.today - 15.days,
                                  :period_end => Date.today + 15.days)
        subject.billable = Factory(:environment, :owner => subject.user)
        (1..5).each do
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

      it "should have a invoice without amount value" do
        @new_plan.invoice.amount.should be_nil
      end

      it "should have a open invoice" do
        @new_plan.invoice.should be_open
      end

    end

    context "when current plan is licensed" do
      before do
        subject.update_attribute(:price, 2.5)
        subject.invoice = Factory(:licensed_invoice,
                                  :state => "pending",
                                  :amount => 25.00,
                                  :period_start => Date.today - 45.days,
                                  :period_end => Date.today - 16.days)
        subject.invoice.licenses << 10.times.collect do
          Factory.build(:license, :invoice => nil,
                        :period_start => Date.today - 45.days,
                        :period_end => nil)
        end

        # Amount 6.25
        subject.invoice = Factory(:licensed_invoice,
                                  :state => "open",
                                  :period_start => Date.today - 15.days,
                                  :period_end => Date.today + 15.days)
        subject.invoice.licenses << 5.times.collect do
          Factory.build(:license, :invoice => nil,
                        :period_start => Date.today - 15.days,
                        :period_end => nil)
        end

        subject.billable = Factory(:environment, :owner => subject.user)

        @new_plan = Factory.build(:active_licensed_plan, :price => 4.5,
                                 :billable => nil)
        subject.migrate_to @new_plan
      end

      it "should add the pending invoice value to the amount too" do
        @new_plan.invoice.should_not be_nil
        @new_plan.invoice.previous_balance.round(2).should == BigDecimal.new("31.25")
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
      }.to change(UserNotifier.deliveries, :count).by(1)
    end
  end


  context "when a plan blocks all billable access" do
    context "when billable is a course" do
      subject { Factory(:plan, :billable => Factory(:complete_course)) }

      before do
        @course = subject.billable
        (1..3).each { @course.join! Factory(:user) }

        subject.block_all_access!
      end

      it "should mark course as blocked" do
        @course.reload.should be_blocked
      end

      it "should mark all spaces as blocked" do
        @course.spaces.each do |space|
          space.reload.should be_blocked
        end
      end

      it "should mark all subjects as blocked" do
        @course.spaces.collect(&:subjects).flatten.each do |subj|
          subj.should be_blocked
        end
      end

      it "should mark all lectures as blocked" do
        subjects = @course.spaces.collect(&:subjects).flatten
        subjects.collect(&:lectures).flatten.each do |subj|
          subj.should be_blocked
        end
      end
    end

    context "when billable is a environment" do
      subject { Factory(:plan, :billable => Factory(:complete_environment)) }

      before do
        @environment = subject.billable
        @environment.courses << Factory(:complete_course,
                                        :environment => @environment)
        @course1, @course2 = @environment.courses
        (1..3).each { @course1.join! Factory(:user) }
        (1..2).each { @course2.join! Factory(:user) }

        subject.block_all_access!
      end

      it "should mark environment as blocked" do
        @environment.reload.should be_blocked
      end

      it "should mark all courses as blocked" do
        @course1.reload.should be_blocked
        @course2.reload.should be_blocked
      end

      it "should mark all spaces as blocked" do
        spaces = (@course1.spaces + @course2.spaces).flatten
        spaces.each do |space|
          space.reload.should be_blocked
        end
      end

      it "should mark all subjects as blocked" do
        subjects = @course1.spaces.collect(&:subjects).flatten +
          @course1.spaces.collect(&:subjects).flatten

        subjects.flatten.each do |subj|
          subj.should be_blocked
        end
      end

      it "should mark all lectures as blocked" do
        subjects = @course1.spaces.collect(&:subjects).flatten +
          @course1.spaces.collect(&:subjects).flatten

        subjects.collect(&:lectures).flatten.each do |lecture|
          lecture.should be_blocked
        end
      end
    end
  end
end

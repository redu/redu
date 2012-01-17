require 'spec_helper'

describe Plan do
  subject { Factory(:plan) }

  it { should belong_to :billable }
  it { should belong_to :user }
  it { should have_one :changed_to }
  it { should have_many :invoices }
  it { should belong_to :changed_from }

  it { should_not allow_mass_assignment_of :state }

  [:members_limit, :price, :yearly_price].each do |attr|
    it { should validate_presence_of attr }
  end

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

  context "when creating new invoices" do
    it "responds to create_invoice" do
      should respond_to :create_invoice
    end

    it "should be valid" do
      invoice = subject.create_invoice()
      invoice.should be_valid
    end

    it "should default to pending" do
      invoice = subject.create_invoice
      invoice.state.should == "pending"
    end

    it "should be successfully" do
      expected_amount = subject.price

      expect {
        @invoice = subject.create_invoice()
      }.should change(subject.invoices, :count).to(1)

      @invoice.amount.round(8).should == expected_amount.round(8)
      @invoice.period_end.should == Date.today.advance(:days => 30)
      @invoice.period_start.should == Date.tomorrow
    end

    it "period_start defaults to tomorrow" do
      subject.create_invoice
      subject.invoices.first.period_start.should == Date.tomorrow
    end

    it "accepts custom attributes" do
      attrs = {
        :description => "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation",
        :period_start => Date.today + 3,
        :period_end => Date.today + 5,
        :amount => BigDecimal.new("21.5")
      }

      invoice = subject.create_invoice(:invoice => attrs)
      invoice.should be_valid

      # Criando instância para o caso de existir algum callback que modifique o
      # modelo
      memo = Factory.build(:invoice, attrs)

      invoice.description.should == memo.description
      invoice.period_start.should == memo.period_start
      invoice.period_end.should == memo.period_end
      invoice.amount.should == memo.amount

    end

    context "when setting up the plan" do
      before do
        UserNotifier.delivery_method = :test
        UserNotifier.perform_deliveries = true
        UserNotifier.deliveries = []

        subject {
          Plan.from_preset(:empresas_plus).save
        }
      end

       it "should create one invoice" do
         expect {
           subject.create_invoice_and_setup
         }.should change(Invoice, :count).by(1)
       end

       it "sends the pending invoice e-mail correctly" do
         invoice = nil

         expect {
           invoice = subject.create_invoice_and_setup
         }.should change(UserNotifier.deliveries, :size).by(1)

        mail = UserNotifier.deliveries.last
        mail.should_not be_nil
        mail.subject.should =~ /Pagamento N\. #{invoice.id} pendente/
       end

       context "the only invoice" do
         it "should have the setup description" do
           subject.create_invoice_and_setup
           subject.invoices.first.description =~ /adesão/
         end

         it "should have the correct amount" do
           subject.create_invoice_and_setup
           subject.invoices.first.amount == subject.price * 2
         end
       end
    end

    context "when generating the amount" do
      it "calculates days in a period" do
        subject.complete_days_in(Date.new(2011,01,14),
                                 Date.new(2011,01,31)).should == 17
      end

      it "responds to amount_until_next_month" do
        should respond_to :amount_until_next_month
      end

      xit "should be proportionally to period until billing date" do
        per_day = subject.price / subject.days_in_current_month
        expected_amount = (period == 0) ? BigDecimal.new("0.0") : (per_day * period)

        expected_amount.should_not be_nil
        expected_amount.should == expected_amount
      end

      it "infers the amount between two dates" do
        subject.update_attribute(:price, 28)
        Date.stub(:today => Date.new(2011,02,14))

        subject.amount_between(Date.today, Date.today + 3).should == BigDecimal("3", 8)
      end
    end
  end

  context "when migrating to a new plan" do
    before do
      @amount_per_day = subject.price / subject.days_in_current_month
      subject.create_invoice(:invoice => {
        :period_start => Date.new(2011, 01, 01),
        :period_end => Date.new(2011, 01, 31),
        :amount =>  31 * @amount_per_day})

      subject.create_invoice(:invoice => {
        :period_start => Date.new(2011, 02, 01),
        :period_end => Date.new(2011, 02, 28),
        :amount =>  28 * @amount_per_day})

      @new_plan = subject.migrate_to(:name => "Novo plano",
                                     :members_limit => 30,
                                     :price => 10,
                                     :yearly_price => 100)
    end

    it "responds to migrate_to" do
      should respond_to :migrate_to
    end

    it "sets state to migrated" do
      subject.state.should == "migrated"
    end

    it "creates a valid and new plan" do
      @new_plan.should be_valid
    end

    it "copies the older plan associations" do
      @new_plan.user.should == subject.user
      @new_plan.billable.should == subject.billable
    end

    it "sets changed to/from associations" do
      subject.changed_to.should == @new_plan
      @new_plan.changed_from == subject
    end

    it "preserves the original invoices" do
      subject.invoices.to_set.should be_subset(@new_plan.invoices.to_set)
    end
  end

  context "when upgrading" do
    before do
      # Garantindo que o plano atual é inferior ao próximo
      subject { Factory(:plan, :price => 50, :yearly_price => 150) }

      @amount_per_day = subject.price / subject.days_in_current_month
      subject.create_invoice(:invoice => {
        :period_start => Date.new(2011, 01, 01),
        :period_end => Date.new(2011, 01, 31),
        :amount =>  31 * @amount_per_day})

      subject.create_invoice(:invoice => {
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

  it { should respond_to :create_order }

  context "when creating a new order" do
    it "should return a valid order object" do
      subject.create_order.should be_instance_of(PagSeguro::Order)
    end

    it "should have the plan ID" do
      subject.create_order.id == subject.id
    end

    context "with custom attributes" do
      before do
        @opts = {
          :order_id => 12,
          :items => [{:id => 13, :price => 12.0}]
        }
      end

      it "accepts custom ID" do
        order = subject.create_order(@opts)
        order.id.should == @opts[:order_id]
      end

      it "accepts custom items" do
        order = subject.create_order(@opts)
        order.products.first == @opts[:items].first
      end
    end

    context "the order" do
      before do
        invoices = 3.times.inject([]) { |res,i|
          invoice = Factory(:invoice, :plan => subject)
          invoice.pend!
          res << invoice
        }

        @products = subject.create_order.products
      end

      it "should have 3 products" do
        @products.should_not be_nil
        @products.size.should == 3
      end
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
        invoice = Factory(:invoice, :plan => subject)
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
        invoice = Factory(:invoice, :plan => subject)
        invoice.overdue!
        acc << invoice
      end
    end

    it "returns true if there are overdue invoices" do
      subject.pending_payment?.should be_true
    end
  end

end

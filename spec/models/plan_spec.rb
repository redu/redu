require 'spec_helper'

describe Plan do
  subject { Factory(:plan) }

  it { should belong_to :billable }
  it { should belong_to :user }
  it { should have_one :changed_to }
  it { should have_many :invoices }
  it { should belong_to :changed_from }

  it { should_not allow_mass_assignment_of :state }

  [:members_limit, :price].each do |attr|
    it { should validate_presence_of attr }
  end

  context "states" do
    [:close!, :migrate!, :current_state].each do |attr|
      it "responds to" do
        should respond_to attr
      end
    end

    it "defaults to active" do
      subject.current_state.should == :active
    end

    it "closes" do
      expect {
        subject.close!
      }.should change { subject.current_state }.to :closed
    end

    it "migrates" do
      expect {
        subject.migrate!
      }.should change { subject.current_state }.to :migrated
    end
  end

  context "when creating new invoices" do
    it "responds to create_invoice" do
      should respond_to :create_invoice
    end

    it "should be successfully" do
      subject.update_attribute(:price, 31)
      expected_amount = (Date.today.at_end_of_month - Date.tomorrow).to_i

      expect {
        subject.create_invoice()
      }.should change(subject.invoices, :count).to(1)

      subject.invoices.first.amount.should be_close(expected_amount, 0.01)
      subject.invoices.first.period_end.should == Date.today.at_end_of_month
      subject.invoices.first.period_start.should == Date.today.tomorrow
    end

    it "the period_start defaults to tomorrow" do
      subject.create_invoice
      subject.invoices.first.period_start.should == Date.tomorrow
    end

    it "accepts custom attributes" do
      attrs = {
        :description => "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation",
        :period_start => Date.today + 3,
        :period_end => Date.today + 5,
        :amount => "21.5"
      }

      invoice = subject.create_invoice(attrs)
      invoice.should be_valid

      # Criando instância para o caso de existir algum callback que modifique o
      # modelo
      memo = Factory.build(:invoice, attrs)

      invoice.description.should == memo.description
      invoice.period_start.should == memo.period_start
      invoice.period_end.should == memo.period_end
      invoice.amount.should be_close(memo.amount, 0.005)

    end

    context "when generating the amount" do
      it "calculates days in a period" do
        subject.days_in_current_month.should == 31

        subject.complete_days_in(Date.new(2011,01,14),
                                 Date.new(2011,01,31)).should == 17
      end

      it "responds to amount_until_next_month" do
        should respond_to :amount_until_next_month
      end

      it "should be proportionally to period until billing date" do
        subject.update_attribute(:price, 31)

        amount = subject.amount_until_next_month
        expected_amount = (Date.today.at_end_of_month - Date.tomorrow).to_i

        amount.should_not be_nil
        amount.should be_close(BigDecimal.new(expected_amount.to_s), 0.01)
      end
    end
  end

  context "when migrating to a new plan" do
    before do
      @new_plan = subject.migrate_to(:name => "Novo plano",
                                    :members_limit => 30, :price => 10)
    end

    it "responds to migrate_to" do
      should respond_to :migrate_to
    end

    it "sets state to migrated" do
      subject.current_state.should == :migrated
    end

    it "creates a valid and new plan" do
      subject.should be_valid
    end

    it "copies the older plan associations" do
      @new_plan.user.should == subject.user
      @new_plan.billable.should == subject.billable
    end

    it "sets changed to/from associations" do
      subject.changed_to.should == @new_plan
      @new_plan.changed_from == subject
    end

    it "sets the invoice correctly"
  end

  it { should respond_to :create_order }

  context "when creating a new order" do
    it "should return a valid order object" do
      subject.create_order.should be_instance_of(PagSeguro::Order)
    end

    context "the order" do
      before do
        @products = subject.create_order.products
      end
    
    it "should have at least one product" do
      @products.should_not be_nil
      @products.should have_at_least(1)
    end
    
    end

    
  end

end

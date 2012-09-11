require 'spec_helper'
require 'set'

describe PackageInvoice do

  subject { Factory(:package_invoice) }

  it { should respond_to :threshold_date }
  it { should respond_to :description }
  it { should validate_presence_of :amount }


  context "threshold date" do
    it "should be overdue days from period start" do
      subject.threshold_date.should == subject.period_start + Invoice::OVERDUE_DAYS
    end
  end

  it "should respond to refresh states" do
    PackageInvoice.should respond_to(:refresh_states!)
  end

  context "when refreshing states" do
    before do
      @period_start = Date.today.advance(:days => - Invoice::OVERDUE_DAYS - 1)
      @period_end = Date.today.advance(:days => 30 - Invoice::OVERDUE_DAYS)

      # 2 invoices que deveriam ficar overdue e uma que deveria continuar
      # pending
      @invoices = 3.times.inject([]) do |acc,i|
        if i % 2 == 0
          invoice = Factory(:package_invoice,
                         :period_start => @period_start,
                         :period_end => @period_end)
          invoice.pend!
          acc << invoice
        else
          invoice = Factory(:package_invoice)
          invoice.pend!
          acc << invoice
        end
      end
    end

    it "should refresh correctly" do
      expect {
        PackageInvoice.refresh_states!
      }.should change { PackageInvoice.overdue.count }.to(2)
    end

    it "should block the plan when overdue" do
      expect {
        PackageInvoice.refresh_states!
      }.should change { Plan.blocked.count }.from(0).to(2)
    end

    it "should not raise error if a plan is already blocked" do
      PackageInvoice.refresh_states!
      inv = Factory(:package_invoice, :plan => Plan.blocked.last,
                    :period_start => @period_start)
      inv.pend!

      expect {
        PackageInvoice.refresh_states!
      }.should_not raise_error(AASM::InvalidTransition)
    end

    it "should generate next invoice" do
      inv = Factory(:package_invoice, :period_start => Date.today - 20.days,
                    :period_end => Date.today - 1.day)
      inv.pend!
      inv.pay!

      PackageInvoice.refresh_states!

      PackageInvoice.pending.should have(2).items
      PackageInvoice.pending.last.should == inv.plan.invoice
    end

    context "when the billable was destroyed" do
      before do
        @inv = Factory(:package_invoice, :period_start => Date.today - 20.days,
                      :period_end => Date.today - 1.day)
        @inv.pend!
        @inv.plan.billable.destroy
        @inv.pay!
      end

      it "should not generate next invoice" do
        PackageInvoice.refresh_states!

        PackageInvoice.pending.should have(1).items
      end
    end
  end

  context " when refreshing paid invoices" do
    before do
      @current_invoices = (1..3).collect do
        attrs = {
          :period_start => Date.today - 60.days,
          :period_end => Date.today - 35.days
        }
        invoice = Factory(:package_invoice)
        invoice.update_attributes(attrs)
        invoice.pend!
        invoice.pay!

        inv = invoice.plan.create_invoice(:invoice => attrs)
        inv.pend!
        inv.pay!
      end
    end

    it "should take in count only current ones" do
      PackageInvoice.refresh_states!
      PackageInvoice.pending.should have(@current_invoices.size).items
    end
  end

  context "states" do
    [:close!, :pend!, :overdue!, :pay!].each do  |attr|
      it "responds to #{attr}" do
        should respond_to attr
      end
    end

    it "defaults to waiting" do
      subject.state.should == "waiting"
    end

    it "closes" do
      expect {
        subject.pend!
        subject.close!
      }.should change(subject, :state).to("closed")
    end

    it "pends" do
      expect {
        subject.pend!
      }.should change(subject, :state).to("pending")
    end

    context "when it pays" do
      before do
        UserNotifier.delivery_method = :test
        UserNotifier.perform_deliveries = true
        UserNotifier.deliveries = []

        subject.plan.block!
        subject.overdue!
      end

      it "changes current state" do
        expect {
          subject.pay!
        }.should change(subject, :state).to("paid")

        subject.due_at.should  be_within(5).of(Time.now)
      end

      it "unblocks the plan" do
        expect {
          subject.pay!
        }.should change { subject.plan.aasm_current_state }.from(:blocked).to(:active)
      end

      it "sends confirmation e-mail" do
        subject.pay!

        mail = UserNotifier.deliveries.last
        mail.should_not be_nil
        mail.subject.should =~ /Pagamento N\. #{subject.id} confirmado/
      end
    end

    context "when it pends" do
      before do
        UserNotifier.delivery_method = :test
        UserNotifier.perform_deliveries = true
        UserNotifier.deliveries = []
      end

      it "sends pending payment e-mail" do
        subject.pend!

        mail = UserNotifier.deliveries.last
        mail.should_not be_nil
        mail.subject.should =~ /Pagamento N\. #{subject.id} pendente/
      end
    end

    it "overdues" do
      expect {
        subject.overdue!
      }.should change(subject, :state).to("overdue")
    end

    context "when overdue" do
      before do
        subject.overdue!
        UserNotifier.delivery_method = :test
        UserNotifier.perform_deliveries = true
        UserNotifier.deliveries = []
      end

      it "stays on same stage if overdue again" do
        expect {
          subject.overdue!
        }.should_not change(subject, :state)
      end

      it "sends overdue e-mail" do
        subject.overdue!
        subject.deliver_overdue_notice

        mail = UserNotifier.deliveries.last
        mail.should_not be_nil
        mail.subject.should =~ /Pagamento N\. #{subject.id} pendente/
        mail.body.should =~ /http:\/\//
      end
    end
  end

  it { should respond_to :to_order_item }

  context "when creating an order item" do
    it "returns a hash of options" do
      subject.to_order_item.should be_kind_of(Hash)
    end

    it "should have the same ID than the invoice by default" do
      subject.to_order_item.fetch(:id, -1).should == subject.id
    end

    it "should have the same price by default" do
      subject.to_order_item.fetch(:price, -1).should == subject.amount
    end

    context "when specifying extra options" do
      before do
        @options = {
          :order_id => 1919,
          :id => 123,
          :price => 10.0,
          :description => "Lorem ipsum dolor sit amet"
        }

        @product = subject.to_order_item(@options)
      end

      it "should have the same options" do
        @product.fetch(:id, nil).should == @options[:id]
        @product.fetch(:price, nil).should == @options[:price]
        @product.fetch(:description, nil).should == @options[:description]
        @product.fetch(:order_id, nil).should == @options[:order_id]
      end
    end
  end

  context "when giving a discount" do
    before do
      subject.update_attribute(:previous_balance, -10.0)
    end

    #FIXME o pagseguro oferece um campo para desconto que o Gem não suporta
    it "should discount from amount" do
      item = subject.to_order_item

      item[:price].should == subject.amount + subject.previous_balance
    end

    it "says something about it" do
      subject.generate_description.should =~ /desconto/
    end
  end

  it { should respond_to :generate_description }

  context "description" do
    it "should generate something" do
      subject.generate_description.should_not be_empty
      subject.generate_description.should_not be_nil
    end
  end

  it "always returns false to open?" do
    subject.should_not be_open
  end

  context "when creating next invoice" do
    before do
      subject.update_attributes(:amount => 50,
                                :plan => Factory(:active_package_plan))
      subject.create_next_invoice
      @new_invoice = subject.plan.invoices.last
    end

    it "should be persisted" do
      @new_invoice.should be_persisted
    end

    it "should have period start one day after last invoice period end" do
      @new_invoice.period_start.should == subject.period_end.tomorrow
    end
  end

  context "when refreshing amount after changing period_end" do
    before do
      # Amount R$ 25.81
      subject.update_attributes(:amount => 50,
                                :period_start => Date.today - 15.days,
                                :period_end => Date.today + 15.days)
      @new_period_end = Date.today
    end

    context "when calling refresh_amount" do
      before do
        @return = subject.refresh_amount(@new_period_end)
      end

      it "should return BigDecimal" do
        @return.should be_kind_of(BigDecimal)
      end

      it "should change period_end to new_period_End" do
        subject.period_end.should == @new_period_end
      end

      it "should return difference between amount and used part of it" do
        @return.round(2).should == BigDecimal.new("24.19")
      end
    end

    context "when calling refresh_amount!" do
      before do
        @return = subject.refresh_amount!(@new_period_end)
      end

      it "should update period_end to new_period_End" do
        subject.period_end.should == @new_period_end
      end

      it "should update amount value to used part of it" do
        subject.amount.round(2).should ==  BigDecimal.new("25.81")
      end
    end
  end
end

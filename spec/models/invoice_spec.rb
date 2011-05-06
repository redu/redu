require 'spec_helper'
require 'set'

describe Invoice do
  subject { Factory(:invoice) }
  it { should belong_to(:plan) }

  [:period_start, :period_end, :amount].each do |attr|
    it { should validate_presence_of attr }
  end

  it { should_not allow_mass_assignment_of :state }

  it { should respond_to :threshold_date }
  it { should respond_to :description }
  it { should respond_to :discount }

  context "threshold date" do
    it "should be 10 days from period end" do
      subject.threshold_date.should == subject.period_end + 10
    end
  end

  context "states" do

    [:close!, :pend!, :overdue!, :pay!].each do  |attr|
      it "responds to #{attr}" do
        should respond_to attr
      end
    end

    it "defaults to pending" do
      subject.state.should == "pending"
    end

    it "closes" do
      expect {
        subject.close!
      }.should change(subject, :state).to("closed")
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

        subject.due_at.should  be_close(Time.now, 5.seconds)
      end

      it "unblocks the plan" do
        expect {
          subject.pay!
        }.should change { subject.plan.state }.from("blocked").to("active")
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

      it "closes" do
        expect {
          subject.close!
        }.should change(subject, :state).to("closed")
      end

      it "pays" do
        expect {
          subject.close!
        }.should change(subject, :state).to("closed")
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
      subject.update_attribute(:discount, 10.0)
    end

    #FIXME o pagseguro oferece um campo para desconto que o Gem não suporta
    it "should discount from amount" do
      item = subject.to_order_item

      item[:price].should == subject.amount - subject.discount
    end

    it "says something about it" do
      subject.generate_description.should =~ /desconto/
    end
  end

  context "finder" do
    it "retrieves pending invoices" do
      plan = Factory :plan
      pending_invoices = (1..5).collect { Factory(:invoice,
                                                  :plan => plan,
                                                  :state => "pending") }
      overdue_invoices = (1..5).collect { Factory(:invoice,
                                                  :plan => plan,
                                                  :state => "overdue") }

      Set.new(plan.invoices.pending) == Set.new(pending_invoices)
    end
  end

  it { should respond_to :generate_description }

  context "description" do
    it "should generate something" do
      subject.generate_description.should_not be_empty
      subject.generate_description.should_not be_nil
    end
  end

  it "should respond to refresh states" do
    Invoice.should respond_to(:refresh_states!)
  end

  context "when refreshing states" do
    before do
      @period_start = Date.today.advance(:days => - Invoice::OVERDUE_DAYS - 1)
      @period_end = Date.today.advance(:days => 30 - Invoice::OVERDUE_DAYS)

      # 2 invoices que deveriam ficar overdue e uma que deveria continuar
      # pending
      @invoices = 3.times.inject([]) do |acc,i|
        if i % 2 == 0
          acc << Factory(:invoice,
                         :period_start => @period_start,
                         :period_end => @period_end)
        else
          acc << Factory(:invoice)
        end
      end
    end

    it "should refresh correctly" do
      expect {
        Invoice.refresh_states!
      }.should change { Invoice.overdue.count }.to(2)
    end

    it "should block the plan when overdue" do
      expect {
        Invoice.refresh_states!
      }.should change { Plan.blocked.count }.from(0).to(2)
    end
  end

end

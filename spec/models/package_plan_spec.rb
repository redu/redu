# -*- encoding : utf-8 -*-
require 'spec_helper'

describe PackagePlan do
  subject { Factory(:active_package_plan) }

  [:members_limit, :yearly_price].each do |attr|
    it { should validate_presence_of attr }
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
      }.to change(subject.invoices, :count).to(1)

      @invoice.amount.round(8).should == expected_amount.round(8)
      @invoice.period_end.should == Date.today.advance(:days => 30)
      @invoice.period_start.should == Date.today
      subject.invoice.should == @invoice
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
          Plan.from_preset(:professor_lite).save
        }
      end

       it "should create one invoice" do
         expect {
           subject.create_invoice_and_setup
         }.to change(Invoice, :count).by(1)
       end

       it "sends the pending invoice e-mail correctly" do
         invoice = nil

         expect {
           invoice = subject.create_invoice_and_setup
         }.to change(UserNotifier.deliveries, :size).by(1)

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
           subject.invoices.first.amount == subject.price + subject.membership_fee
         end

         context "when does not have membership fee" do
           before do
             subject.membership_fee = nil
             subject.save
           end

           it "should have the correct amount" do
             subject.create_invoice_and_setup
             subject.invoices.first.amount == subject.price
           end
         end
       end
    end

    context "when creating invoice with negative total" do
      before do
        @new_invoice = subject.create_invoice(:invoice => {
          :amount => 50,
          :previous_balance => -100
        })
      end

      it "new invoice is marked as paid" do
        @new_invoice.should be_paid
      end
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
          invoice = Factory(:package_invoice, :plan => subject)
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
end

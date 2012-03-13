require 'spec_helper'

describe LicensedInvoice do
  subject { Factory(:licensed_invoice,
                    :plan => Factory(:active_licensed_plan)) }

  it { should belong_to :plan }
  it { should have_many :licenses }
  it { should validate_presence_of :period_start }
  it { should respond_to :generate_description }

  context "when having state machine" do
    before do
      UserNotifier.delivery_method = :test
      UserNotifier.perform_deliveries = true
    end

    it "should defaults to open" do
      should be_open
    end

    [:state, :pend!, :pay!, :overdue!].each do |attr|
      it "should respond_to #{attr}" do
        should respond_to attr
      end
    end

    context "when open" do
      before do
        UserNotifier.deliveries = []

        subject.pend!
      end

      it "should change to pending" do
        should be_pending
      end

      it "should calculate the amount" do
        subject.amount.should_not be_nil
      end

      it "should send an email" do
        UserNotifier.deliveries.size.should == 1
        UserNotifier.deliveries.last.body.should =~ /com pagamento pendente/
      end
    end

    context "when pending" do
      before do
        subject.update_attribute(:state, "pending")
      end

      context "when pending again" do
        before do
          UserNotifier.deliveries = []

          subject.pend!
        end

        it "should continue to be pending" do
          subject.should be_pending
        end

        it "should send an email" do
          UserNotifier.deliveries.size.should == 1
          UserNotifier.deliveries.last.body.should =~
            /está com pagamento pendente/
        end
      end

      context "when paying" do
        before do
          subject.pay!
        end

        it "should change to paid" do
          subject.should be_paid
        end

        it "should register time" do
          subject.due_at.should_not be_nil
        end
      end

      context "when overduing" do
        before do
          UserNotifier.deliveries = []

          subject.overdue!
        end

        it "should change to overdue" do
          subject.should be_overdue
        end

        it "should send an email" do
          UserNotifier.deliveries.size.should == 1
          UserNotifier.deliveries.last.body.should =~
          /os serviços estão suspensos/
        end
      end

      context "when invoice is not paid in correct time" do
        before do
          Date.stub(:today) do
            subject.period_end + Invoice::OVERDUE_DAYS + 1.day
          end
          UserNotifier.delivery_method = :test
          UserNotifier.perform_deliveries = true
          UserNotifier.deliveries = []

          LicensedInvoice.refresh_states!
        end

        it "should change to overdue" do
          subject.reload.should be_overdue
        end

        it "should block plan" do
          subject.plan.reload.should be_blocked
        end

        it "should send an email about invoice" do
          UserNotifier.deliveries.size.should == 2
          UserNotifier.deliveries.first.body.should =~
          /os serviços estão suspensos/
        end

        it "should send an email about blocked plan" do
          UserNotifier.deliveries.size.should == 2
          UserNotifier.deliveries.last.body.should =~ /foi bloqueado/
        end
      end
    end

    context "when overdue" do
      before do
        subject.update_attribute(:state, 'overdue')
        subject.plan.block!

        UserNotifier.deliveries = []
      end

      context "when paying" do
        before do
          subject.pay!
        end

        it "should change to paid" do
          subject.should be_paid
        end

        it "should send an email" do
          UserNotifier.deliveries.size.should == 1
          UserNotifier.deliveries.last.body =~ /foi confirmado em #{subject.due_at}/
        end

        it "should unblock plan" do
          subject.plan.reload.should_not be_blocked
        end
      end
    end
  end

  context "description" do
    before do
      @plan = Plan.from_preset(PackagePlan::PLANS[:empresa_plus], "PackagePlan")
      subject.plan = @plan
      subject.save
      subject.reload
    end

    it "should generate something" do
      subject.generate_description.should_not be_nil
      subject.generate_description.should_not be_empty
    end
  end

  context "retrivers" do
    it "should retrieve all licensed invoices within certain month and year" do
      os1 = Factory(:licensed_invoice, :period_start => "2011-10-01", :period_end => "2011-10-31")
      os2 = Factory(:licensed_invoice, :period_start => "2011-12-01", :period_end => "2011-12-31")
      os3 = Factory(:licensed_invoice, :period_start => "2012-01-01", :period_end => "2012-01-15")
      os4 = Factory(:licensed_invoice, :period_start => "2012-01-16", :period_end => "2012-01-31")

      LicensedInvoice.retrieve_by_month_year(1, 2012).to_set.should == [os3, os4].to_set
    end

    it "should retrieve actual licensed invoice" do
      os1 = Factory(:licensed_invoice, :period_start => "2011-12-01", :period_end => "2011-12-31")
      os2 = Factory(:licensed_invoice, :period_start => "2012-01-01", :period_end => "2012-01-15")
      os3 = Factory(:licensed_invoice, :period_start => "2012-01-16", :period_end => "2012-01-31")

      LicensedInvoice.actual.should == [os3]
    end
  end

  it "LicensedPlan should respond to refresh_states!" do
    LicensedInvoice.respond_to?(:refresh_states!).should be_true
  end

  context "when verifying protected methods" do
    before do
      user = Factory(:user)
      environment = Factory(:environment, :owner => user)
      course = Factory(:course, :environment => environment,
                       :owner => user)
      @plan = Factory(:active_licensed_plan, :price => 3.00,
                      :billable => environment)
      from = Date.new(2010, 01, 15)
      @plan.create_invoice({:invoice => {
        :period_start => from,
        :period_end => from.end_of_month }
      })
      @invoice = @plan.invoices.last

      (1..10).collect do
        Factory(:license, :invoice => @invoice, :course => course,
                :role => Role[:member])
      end
      (1..3).collect do
        Factory(:license, :invoice => @invoice, :course => course,
                :role => Role[:teacher])
        Factory(:license, :invoice => @invoice, :course => course,
                :role => Role[:tutor])
        Factory(:license, :invoice => @invoice, :course => course,
                :role => Role[:environment_admin])
      end
      @in_use_licenses = (1..10).collect do
        Factory(:license, :invoice => @invoice, :period_end => nil,
                :course => course, :role => Role[:member])
      end

    end

    context "when calculating amount" do
      before do
        @invoice.send(:calculate_amount!)
      end

      it "updates to the correct amount" do
        @invoice.amount.round(2).should == BigDecimal.new("32.90")
      end
    end

    context "when creating next invoice" do
      before do
        @invoice.send(:create_next_invoice)
        @new_invoice = @invoice.plan.invoices.last
      end

      it "should be persisted" do
        @new_invoice.should be_persisted
      end

      it "should have period start one day after last invoice period end" do
        @new_invoice.period_start.should == @invoice.period_end.tomorrow
      end
    end

    context "when duplicating licenses" do
      before do
        @new_invoice = @plan.create_invoice(:invoice => {
          :created_at => Time.now + 2.hours})
          @invoice.send(:replicate_licenses_to, @new_invoice)
      end

      it "should have all licenses without period_end (at the end of month)" do
        @new_invoice.licenses.should_not be_empty
        @new_invoice.licenses.each_with_index do |l, i|
          l.name.should == @in_use_licenses[i].name
          l.email.should == @in_use_licenses[i].email
        end
      end
    end
  end

  context "when refreshing open licensed invoices" do
    before do
      user = Factory(:user)
      environment = Factory(:environment, :owner => user)
      course = Factory(:course, :environment => environment,
                       :owner => user)
      @plan1 = Factory(:active_licensed_plan, :price => 3.00,
                       :billable => environment)

      plan2 = Factory(:active_licensed_plan, :price => 4.00)

      from = Date.new(2010, 01, 10)
      @to = Date.new(2010, 01, 20)
      @plan1.create_invoice({:invoice => {
        :period_start => from,
        :period_end => @to,
        :created_at => Time.now - 1.hour }
      })
      @invoice1 = @plan1.invoices.last

      from = Date.today
      plan2.create_invoice({:invoice => {
        :period_start => from }
      })
      @invoice2 = plan2.invoices.last

      @in_use_licenses = (1..10).collect do
        Factory(:license, :invoice => @invoice1, :period_end => nil,
                :course => course)
      end
      (1..20).collect { Factory(:license, :invoice => @invoice1,
                                :course => course) }
      (1..20).collect { Factory(:license, :invoice => @invoice2,
                                :course => course) }

      Date.stub(:today) { @to }
      LicensedInvoice.refresh_states!
      @invoice1.reload
      @invoice2.reload
    end

    it "should change invoice1 to be pending" do
      @invoice1.should be_pending
    end

    it "should maintain invoice2 as open" do
      @invoice2.should be_open
    end

    it "should calculates invoice1's relative amount" do
      @invoice1.reload.amount.round(2).should == BigDecimal.new("31.94")
    end

    it "should NOT calculate invoice2's relative amount" do
      @invoice2.amount.should be_nil
    end

    context "when generating a new invoice" do
      it "should generate a new invoice" do
        @plan1.invoices.length.should == 2
      end

      it "should return the correct invoice" do
        @plan1.invoice.should_not == @invoice1
      end

      it "should have the correct dates" do
        @plan1.invoice.period_start.should == @to + 1.day
        @plan1.invoice.period_end.should == @to + 1.month
      end

      it "should have all licenses without period_end (at the end of month)" do
        @plan1.invoice.licenses.should_not be_empty
        @plan1.invoice.licenses.each_with_index do |l, i|
          l.name.should == @in_use_licenses[i].name
          l.email.should == @in_use_licenses[i].email
        end
      end

      it "should update period_end of all in use licenses with invoice period end" do
        invoice = @plan1.invoices.first
        invoice.licenses.in_use.should be_empty
        @in_use_licenses.first.reload.period_end.should == invoice.period_end
      end
    end

    context "when refreshing states again" do
      before do
        UserNotifier.deliveries = []

        LicensedInvoice.refresh_states!
      end

      it "should re-send pending notice from invoice1" do
        UserNotifier.deliveries.size.should == 1
        UserNotifier.deliveries.last.body =~
        /a fatura com número ##{@invoice1.id} [a-z]+ está com pagamento pendente/
      end
    end
  end

  context "threshold date" do
    it "should be overdue days from period end" do
      subject.threshold_date.should == subject.period_end + Invoice::OVERDUE_DAYS
    end
  end
end

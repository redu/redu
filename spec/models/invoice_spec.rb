require 'spec_helper'

describe Invoice do
  subject { Factory(:invoice) }
  it { should belong_to(:plan) }

  [:period_start, :period_end, :amount].each do |attr|
    it { should validate_presence_of attr }
  end

  it { should_not allow_mass_assignment_of :state }

  it { should respond_to :threshold_date }

  context "threshold date" do
    it "should be 10 days from period end" do
      subject.threshold_date.should == subject.period_end + 10
    end
  end

  context "states" do

    [:close!, :overdue!, :pay!].each do  |attr|
      it "responds to #{attr}" do
        should respond_to attr
      end
    end

    it "defaults to pending" do
      subject.current_state.should == :pending
    end

    it "closes" do
      expect {
        subject.close!
      }.should change(subject, :current_state).to(:closed)
    end

    context "when it pays" do
      before do
        UserNotifier.delivery_method = :test
        UserNotifier.perform_deliveries = true
        UserNotifier.deliveries = []
      end

      it "changes current state" do
        expect {
          subject.pay!
        }.should change(subject, :current_state).to(:paid)

        subject.due_at.should  be_close(Time.now, 5.seconds)
      end

      it "sends confirmation e-mail" do
        subject.pay!

        mail = UserNotifier.deliveries.last
        mail.should_not be_nil
        mail.subject.should =~ /Pagamento N\. #{subject.id} confirmado/
      end
    end

    it "overdues" do
      expect {
        subject.overdue!
      }.should change(subject, :current_state).to(:overdue)
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
        }.should change(subject, :current_state).to(:closed)
      end

      it "pays" do
        expect {
          subject.close!
        }.should change(subject, :current_state).to(:closed)
      end

      it "stays on same stage if overdue again" do
        expect {
          subject.overdue!
        }.should_not change(subject, :current_state)
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
end

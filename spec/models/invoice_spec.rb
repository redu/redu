require 'spec_helper'

describe Invoice do
  subject { Factory(:invoice) }
  it { should belong_to(:plan) }

  [:period_start, :period_end, :amount].each do |attr|
    it { should validate_presence_of attr }
  end

  it { should_not allow_mass_assignment_of :state }

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

    it "pays" do
      expect {
        subject.pay!
      }.should change(subject, :current_state).to(:paid)
    end

    it "overdues" do
      expect {
        subject.overdue!
      }.should change(subject, :current_state).to(:overdue)
    end

    context "when overdue" do
      before do
        subject.overdue!
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
    end
  end
end

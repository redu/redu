require 'spec_helper'

describe Plan do
  subject { Factory(:plan) }

  it { should belong_to :billable }
  it { should belong_to :user }
  it { should have_one :changed_to }
  it { should have_many :invoices }
  it { should belong_to :changed_from }

  it { should_not allow_mass_assignment_of :state }

  [:members_limit, :price ].each do |attr|
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
    it "accesses global billing date" do

    end
    it "responds to create_invoice" do
      should respond_to :create_invoice
    end
    it "sets the association"
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

end

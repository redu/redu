# -*- encoding : utf-8 -*-
shared_examples_for "a billable" do
  it { should have_many(:plans) }
  it { should have_one(:quota).dependent(:destroy) }
  it { should respond_to :plan }
  it { should respond_to :plan= }

  context "when dealing with current plan" do
    before do
      subject.plans = []
    end

    it "should retrieve the current plan" do
      plan1 = FactoryGirl.create(:plan, :billable => subject, :current => false)
      plan2 = FactoryGirl.create(:plan, :billable => subject)
      subject.reload

      subject.plan.should == plan2
    end

    it "should store the plan as current" do
      plans = (1..2).collect do
        FactoryGirl.create(:plan, :billable => subject, :current => false)
      end
      subject.reload

      plan1 = FactoryGirl.build(:plan)
      subject.plan = plan1
      subject.save
      subject.plan.should == plan1

      plan2 = FactoryGirl.create(:plan)
      subject.plan = plan2
      subject.plan.should == plan2

      subject.plans.to_set.should == (plans << plan1 << plan2).to_set
    end

    it "should return nil as current" do
      plans = (1..2).collect do
        FactoryGirl.create(:plan, :billable => subject, :current => false)
      end
      subject.reload

      plan1 = FactoryGirl.create(:plan)
      subject.plan = plan1

      subject.plan = nil
      subject.plan.should be_nil
    end
  end

  it "should stores itself ond plan and self destroy" do
    FactoryGirl.create(:plan, :billable => subject)
    subject.should_receive(:async_destroy)
    subject.audit_billable_and_destroy
    subject.plan.billable_audit.should_not be_nil
  end

  context "Quotas" do
    it "retrieve a percentage of quota file" do
      billable.quota.files = 512
      billable.quota.save
      billable.percentage_quota_file.should == 50
    end

    it "retrieve a percentage of quota multimedia" do
      billable.quota.multimedia = 512
      billable.quota.save
      billable.percentage_quota_multimedia.should == 50
    end

    it "retrieve a percentage of a members" do
      billable.percentage_quota_members == 50
    end
  end
end

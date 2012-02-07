shared_examples_for "a billable" do
  it { should have_many(:plans) }
  it { should have_one(:quota).dependent(:destroy) }
  it { should respond_to :plan }

  it "should retrieves the current plan" do
    subject.plans = []
    plan1 = Factory(:plan, :billable => subject, :created_at => 2.days.ago)
    plan2 = Factory(:plan, :billable => subject)
    subject.reload

    subject.plan.should == plan2
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

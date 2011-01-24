require 'spec_helper'

describe AssetReport do
  subject { Factory(:asset_report) }
  it { should belong_to :student_profile }
  it { should belong_to :lecture }
  it { should belong_to :subject }

  it "responds to done" do
    should respond_to :done
  end

  context "finders" do
    it "retrieves done asset reports" do
     assets_done = (1..2).collect { Factory(:asset_report, :done => true) }
     assets = (1..2).collect { Factory(:asset_report) }

     AssetReport.done.should == assets_done
    end

    it "retrieves asset reports of a subject"  do
      subject1 = Factory(:subject)
      subject_assets = (1..3).collect { Factory(:asset_report,
                                                :subject => subject1)}
      another_assets = (1..3).collect { Factory(:asset_report) }
      AssetReport.of_subject(subject1).should == subject_assets
    end

    it "retrieves asset reports of a user" do
      users = (1..2).collect { Factory(:user) }
      subject1 = Factory(:subject)
      subject1.enroll(users[0])
      subject1.enroll(users[1])
      AssetReport.of_user(users[0]).
        should == users[0].student_profiles.last.asset_reports
    end
  end

end

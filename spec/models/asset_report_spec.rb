require 'spec_helper'

describe AssetReport do
  before do
    @space = Factory(:space)
    @subject_owner = Factory(:user)
    @space.course.join(@subject_owner)
    sub = Factory(:subject, :owner => @subject_owner, :space => @space)
    @lecture = Factory(:lecture, :owner => @subject_owner, :subject => sub)
    enrollment = Factory(:enrollment, :subject => sub)
    @student_profile = Factory(:student_profile, :subject => sub,
                                :enrollment => enrollment)
  end
  subject { Factory(:asset_report, :lecture => @lecture,
                    :student_profile => @student_profile) }
  it { should belong_to :student_profile }
  it { should belong_to :lecture }
  it { should belong_to :subject }

  it "responds to done" do
    should respond_to :done
  end

  context "finders" do
    it "retrieves done asset reports" do
     assets_done = (1..2).collect { Factory(:asset_report,
                                            :lecture => @lecture,
                                            :student_profile => @student_profile,
                                            :done => true) }
     assets = (1..2).collect { Factory(:asset_report,
                                       :lecture => @lecture,
                                       :student_profile => @student_profile) }

     AssetReport.done.should == assets_done
    end

    it "retrieves asset reports of a subject"  do
      # Utiliza Assets do owner
      subject1 = Factory(:subject, :owner => @subject_owner,
                         :space => @space)
      subject2 = Factory(:subject, :owner => @subject_owner,
                         :space => @space)
      expected_assets = subject1.reload.enrollments.collect do
        |e| e.student_profile.asset_reports
      end

      AssetReport.of_subject(subject1).should == expected_assets.flatten
    end

    it "retrieves asset reports of a user" do
      users = (1..2).collect { Factory(:user) }
      subject1 = Factory(:subject, :owner => @subject_owner,
                         :space => @space)
      lecture = Factory(:lecture, :owner => @subject_owner, :subject => subject1)

      subject1.enroll(users[0])
      subject1.enroll(users[1])
      AssetReport.of_user(users[0]).to_set.
        should == users[0].student_profiles.last.asset_reports.to_set
    end
  end

end

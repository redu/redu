require 'spec_helper'

describe StudentProfile do

  before do
    @space = Factory(:space)
    @subject_owner = Factory(:user)
    @space.course.join(@subject_owner)
    # Se usar @subject conflita com subject
    @sub = Factory(:subject, :owner => @subject_owner, :space => @space)
  end

  subject { @sub.enrollments.last.student_profile }

  it { should belong_to :user }
  it { should belong_to :subject }
  it { should belong_to :enrollment }
  it { should have_many(:asset_reports).dependent :destroy }
  it { should have_many(:lectures).through :asset_reports }

  # FIXME Erro de tradução
  xit { should validate_uniqueness_of(:user_id).scoped_to :subject_id }

  it "responds to grade" do
    should respond_to :grade
  end

  it "responds to graduated" do
    should respond_to :graduaded
  end

  context "callbacks" do
    it "creates all assets reports after create" do
      subject_entity = Factory(:subject, :owner => @subject_owner,
                               :space => @space)
      lectures = (1..3).collect { Factory(:lecture, :subject => subject_entity) }
      new_user = Factory(:user)
      subject_entity.space.course.join(new_user)
      expect {
        subject_entity.enroll(new_user)
      }.should change {
        AssetReport.count
      }.by(subject_entity.lectures.count)
    end
  end

  context "retrievers" do
    it "retrieves student profile of a specified Subject" do
      @subjects = (1..3).collect { Factory(:subject, :owner => @subject_owner,
                                           :space => @space) }
      user = Factory(:user)
      @space.course.join user
      @subjects.each do |sub|
        sub.enroll user
      end

      user.student_profiles.of_subject(@subjects[1]).
        should == [user.student_profiles[1]]
    end
  end

  context "grade" do
    it "responds to update_grade!" do
      should respond_to :update_grade!
    end

    it "updates grade successfully" do
      lectures = (1..3).collect { Factory(:lecture, 
                                          :subject => @sub,
                                          :owner => @sub.owner) }
      subject.asset_reports[0..1].each { |a| a.done = true; a.save }
      expect {
        subject.update_grade!
      }.should change(subject, :grade).by_at_most(66.6666666666667 + 10e-5).
        by_at_least(66.6666666666667 - 10e-5) # Aproximação
      subject.graduaded.should be_false
    end

    it "mark student profile as graduated when all grade is completed" do
      subject_entity = Factory(:subject, :owner => @subject_owner,
                               :space => @space)
      lectures = (1..3).collect { Factory(:lecture, :subject => subject_entity) }
      subject = Factory(:student_profile, :subject => subject_entity,
                        :enrollment => @enrollment)
      subject.asset_reports.each { |a| a.done = true; a.save }
      subject.update_grade!
      subject.graduaded.should be_true
    end
  end
end

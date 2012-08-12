require 'spec_helper'

describe Enrollment do

  before do
    subject_owner = Factory(:user)
    @space = Factory(:space)
    @space.course.join subject_owner
    @sub = Factory(:subject, :owner => subject_owner,
                       :space => @space)
  end
  subject { Factory(:enrollment, :subject => @sub) }

  it { should belong_to :user }
  it { should belong_to :subject }
  it { should have_many(:asset_reports).dependent :destroy }

  it "responds to grade" do
    should respond_to :grade
  end

  it "responds to graduated" do
    should respond_to :graduaded
  end

  context "callbacks" do
    it "creates all assets reports after create" do
      lectures = (1..3).collect { Factory(:lecture, :subject => @sub) }
      new_user = Factory(:user)
      @sub.space.course.join(new_user)
      expect {
        @sub.enroll(new_user)
      }.should change {
        AssetReport.count
      }.by(@sub.lectures.count)
    end
  end

  context "grade" do
    let :lectures do
      3.times.collect do
        Factory(:lecture, :subject => @sub, :owner => @sub.owner)
      end
    end

    it "responds to update_grade!" do
      should respond_to :update_grade!
    end

    it "updates grade successfully" do
      lectures
      subject.asset_reports[0..1].each { |a| a.done = true; a.save }
      expect {
        subject.update_grade!
      }.should change(subject, :grade).by_at_most(66.6666666666667 + 10e-5).
        by_at_least(66.6666666666667 - 10e-5) # Aproximação
      subject.graduaded.should be_false
    end

    it "marks as graduated when all grade is completed" do
      lectures
      subject.asset_reports.each { |a| a.done = true; a.save }
      subject.update_grade!
      subject.graduaded.should be_true
    end

    it "changes to false when more lectures are added" do
      lectures
      subject.asset_reports.each { |a| a.done = true; a.save }
      subject.update_grade!

      expect {
        Factory(:lecture, :subject => @sub, :owner => @sub.owner)
        subject.reload
        subject.update_grade!
      }.should change(subject, :graduaded).to(false)
    end
  end

  context "when application validation fail" do
    it "should prevent duplicate subject_id and user_id" do
      @duplicate = Factory.build(:enrollment, :subject_id => subject.subject_id,
                                 :user_id => subject.user_id)
      expect {
        @duplicate.save(:validate => false)
      }.should raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end

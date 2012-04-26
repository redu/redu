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
        subject.update_grade!
      }.should change(subject, :graduaded).to(false)
    end

    it "when grade is full should send a notification to vis" do
      WebMock.disable_net_connect!
      @stub = stub_request(:post, Redu::Application.config.vis_client[:url]).
        with(:headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                          'Content-Type'=>'application/json'}).
                          to_return(:status => 200, :body => "", :headers => {})
      lectures
      subject.asset_reports.each { |a| a.done = true; a.save }
      subject.update_grade!

      params = {
        :user_id => subject.user_id,
        :lecture_id => nil,
        :subject_id => subject.subject_id,
        :space_id => subject.subject.space.id,
        :course_id => subject.subject.space.course.id,
        :type => "subject_finalized",
        :status_id => nil,
        :statusable_id => nil,
        :statusable_type => nil,
        :in_response_to_id => nil,
        :in_response_to_type => nil,
        :created_at => subject.created_at,
        :updated_at => subject.updated_at
      }

      a_request(:post, Redu::Application.config.vis_client[:url]).
        with(:body => params.to_json,
             :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                          'Content-Type'=>'application/json'}).should have_been_made

    end
  end
end

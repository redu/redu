# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Subject do
  before do
    environment = FactoryBot.create(:environment)
    @course = FactoryBot.create(:course, :owner => environment.owner,
                     :environment => environment)
    @space = FactoryBot.create(:space, :owner => environment.owner,
                    :course => @course)
    @user = FactoryBot.create(:user)
    @course.join(@user)
  end


  subject { FactoryBot.create(:subject, :owner => @user, :space => @space) }

  it { should belong_to :space }
  it { should belong_to :owner }
  it { should have_many(:lectures).dependent(:destroy) }
  it { should have_many(:enrollments).dependent(:destroy) }
  it { should have_many(:graduated_members).through :enrollments }
  it { should have_many(:members).through(:enrollments) }
  it { should have_many(:statuses) }
  it { should have_many(:logs) }
  it { should have_many(:asset_reports) }

  it { should validate_presence_of :name }
  #FIXME falhando por problema de tradução
  xit { should ensure_length_of(:description).is_at_least(30).is_at_most(250) }

  it { should_not allow_mass_assignment_of(:owner) }
  it { should_not allow_mass_assignment_of(:finalized) }

  context "callbacks" do

    it "creates an Enrollment between the Subject and the owner after create" do
      subject.enroll
      subject.enrollments.first.should_not be_nil
      subject.enrollments.last.user.should == subject.owner
      subject.enrollments.last.role.
        should == subject.owner.get_association_with(subject.space).role
      subject.enrollments.count.should == 2
    end

    it "does NOT create an Enrollment between the Subject and the owner when update it" do
      expect {
        subject.save # Other updates
      }.to_not change(subject.enrollments.reload, :count)
    end

    it "does NOT create an Enrollment between the subject and the owner after create, if the owner is a Redu admin" do
      redu_admin = FactoryBot.create(:user, :role => Role[:admin])
      expect {
        FactoryBot.create(:subject, :owner => redu_admin, :space => @space)
      }.to_not change(Enrollment, :count)
    end

  end

  context "finders" do
    it "retrieves visibles subjects" do
      subjects = (1..3).collect { FactoryBot.create(:subject, :owner => @user,
                                          :space => @space, :visible => false) }
      visible_subjects = (1..3).collect { FactoryBot.create(:subject, :owner => @user,
                                                    :space => @space,
                                                    :visible => true) }
      Subject.visible.should == visible_subjects
    end

    it "retrieves recent subjects (created until 1 week ago)" do
      subjects = (1..3).collect { |i| FactoryBot.create(:subject, :owner => @user,
                                              :space => @space,
                                              :created_at => (i*3).day.ago) }
      Subject.recent.should == subjects[0..1]
    end

    it "retrieves graduated members" do
      users = (1..4).collect { FactoryBot.create(:user) }
      users.each { |u| subject.enroll(u) }
      users[0..1].each do |u|
        student_profile = u.enrollments.last
        student_profile.graduated = 1
        student_profile.save
      end

      subject.graduated_members.should == users[0..1]
    end

    it "retrieves teachers" do
      users = (1..4).collect { FactoryBot.create(:user) }
      teachers = (1..4).collect { FactoryBot.create(:user) }
      users.each { |u| subject.enroll(u) }
      teachers.each { |u| subject.enroll(u, :role => Role[:teacher]) }

      subject.teachers.should == teachers
    end
  end

  it "responds to recent?" do
    should respond_to :recent?
  end

  it "indicates if it is recent (created until 1 week ago)" do
    subject.should be_recent

    subject.created_at = 10.day.ago
    subject.save
    subject.should_not be_recent
  end


  it "responds to graduated?" do
    should respond_to :graduated?
  end

  context "lectures" do
    it "changes lectures order" do
      lectures = (1..4).collect { FactoryBot.create(:lecture, :subject => subject)}
      lectures_ordered = ["#{lectures[1].id}-lecture", "#{lectures[0].id}-lecture",
        "#{lectures[3].id}-lecture", "#{lectures[2].id}-lecture"]
      subject.change_lectures_order!(lectures_ordered)
      subject.reload.lectures.should == [lectures[1], lectures[0],
                                    lectures[3], lectures[2]]
    end
  end

  it "verifies if a user completed the subject" do
    FactoryBot.create(:lecture, :subject => subject, :owner => subject.owner)
    graduated = FactoryBot.create(:user)
    subject.enroll(graduated)
    subject.lectures.each { |l| l.mark_as_done_for!(graduated, true) }
    e = graduated.get_association_with(subject)
    e.update_grade!

    subject.graduated?(graduated).should be_true
  end

  it "verifies if a user did not complete the subject" do
    enrolled_user = FactoryBot.create(:user)
    subject.enroll(enrolled_user)
    subject.graduated?(enrolled_user).should be_false
  end

  it "verifies if a not enrolled user did not complete the subject" do
    unenrolled_user = FactoryBot.create(:user)
    subject.graduated?(unenrolled_user).should be_false
  end

  it "should remove subjects unfinalized that was created more then 1 days ago" do
    3.times do
      FactoryBot.create(:subject, :owner => @user, :space => @space,
              :visible => true, :created_at => 2.days.ago)
    end
    subject

    expect {
      Subject.destroy_subjects_unfinalized
    }.to change(Subject, :count).by(-3)
  end
end

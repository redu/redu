require 'spec_helper'

describe Subject do
  subject { Factory(:subject) }

  it { should validate_presence_of :title }
  #FIXME falhando por problema de tradução
  xit { should ensure_length_of(:description).is_at_least(30).is_at_most(200) }

  it { should belong_to :space }
  it { should belong_to :owner }
  it { should have_many(:lectures).dependent(:destroy) }
  it { should have_many(:enrollments).dependent(:destroy) }
  it { should have_many(:graduated_members).through :enrollments }
  it { should have_many(:members).through(:enrollments).dependent(:destroy) }

  it { should_not allow_mass_assignment_of(:owner) }
  it { should_not allow_mass_assignment_of(:published) }

  it "responds to tags" do
    should respond_to :tag_list
  end

  context "validations" do
    it "validates that it has at least one lecture on update" do
      subject = Factory(:subject)
      subject.lectures = []
      subject.save
      subject.should_not be_valid
      subject.errors.on(:lectures).should_not be_nil
    end
  end

  it "defaults to not published" do
    subject { Factory(:subject, :published => nil) }
    subject.published.should be_false
  end

  it "responds to enroll" do
    should respond_to :enroll
  end

  it "responds to unenroll" do
    should respond_to :unenroll
  end

  context "enrollments" do
    before :each do
      @user = Factory(:user)
    end

    it "enrolls an user" do
      expect {
        subject.enroll(@user)
      }.should change(subject.enrollments, :count).by(1)
    end

    it "enrolls an user with a given role" do
      subject.enroll(@user, Role[:teacher]).should be_true
      subject.enrollments.first.role_id.should == Role[:teacher].id
    end

    it "unenrolls an user" do
      enrollment = Factory(:enrollment, :user_id => @user, :subject => subject)

      expect {
        subject.unenroll(@user)
      }.should_not change(subject.enrollments, :count)
    end
  end

  it "retrieves graduated members" do
    users = (1..4).collect { Factory(:user) }
    users.each { |u| subject.enroll(u) }
    users[0..1].each do |u|
      student_profile = u.student_profiles.last
      student_profile.graduaded = 1
      student_profile.save
    end

    subject.graduated_members.should == users[0..1]
  end
end

require 'spec_helper'

describe Subject do
  before do
    environment = Factory(:environment)
    course = Factory(:course, :owner => environment.owner,
                     :environment => environment)
    @space = Factory(:space, :owner => environment.owner,
                    :course => course)
    @user = Factory(:user)
    course.join(@user)
  end


  subject { Factory(:subject, :owner => @user, :space => @space) }

  it { should belong_to :space }
  it { should belong_to :owner }
  it { should have_many(:lectures).dependent(:destroy) }
  it { should have_many(:enrollments).dependent(:destroy) }
  it { should have_many(:graduated_members).through :enrollments }
  it { should have_many(:members).through(:enrollments) }
  it { should have_many(:statuses).dependent(:destroy) }
  it { should have_many(:logs).dependent(:destroy) }

  it { should validate_presence_of :title }
  #FIXME falhando por problema de tradução
  xit { should ensure_length_of(:description).is_at_least(30).is_at_most(250) }

  it { should_not allow_mass_assignment_of(:owner) }
  it { should_not allow_mass_assignment_of(:published) }
  it { should_not allow_mass_assignment_of(:finalized) }

  it "responds to tags" do
    should respond_to :tag_list
  end

  context "validations" do
    it "validates that it has at least one lecture on update" do
      subject = Factory(:subject, :owner => @user, :space => @space)
      subject.lectures = []
      subject.save
      subject.should_not be_valid
      subject.errors.on(:lectures).should_not be_nil
    end
  end

  context "callbacks" do
    it "creates a Enrollment between the Subject and the owner after finalize it" do
      subject.save # First update (finalize the subject)
      subject.enrollments.first.should_not be_nil
      subject.enrollments.first.user.should == subject.owner
      subject.enrollments.first.role.
        should == subject.owner.get_association_with(subject.space).role
    end

    it "does NOT create a Enrollment between the Subject and the owner when update it" do
      subject.save # First update
      expect {
        subject.save # Other updates
      }.should_not change(Enrollment, :count)
    end

    it "does NOT create a Enrollment between the subject and the owner after create, if the owner is a Redu admin" do
      redu_admin = Factory(:user, :role => Role[:admin])
      expect {
        Factory(:subject, :owner => redu_admin)
      }.should_not change(Enrollment, :count)
    end
  end

  context "finders" do
    it "retrieves published subjects" do
      subjects = (1..3).collect { Factory(:subject, :owner => @user,
                                          :space => @space) }
      published_subjects = (1..3).collect { Factory(:subject, :owner => @user,
                                                    :space => @space,
                                                    :published => true) }
      Subject.published.should == published_subjects
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

    it "retrieves teachers" do
      users = (1..4).collect { Factory(:user) }
      teachers = (1..4).collect { Factory(:user) }
      users.each { |u| subject.enroll(u) }
      teachers.each { |u| subject.enroll(u, Role[:teacher]) }

      subject.teachers.should == teachers
    end
  end

  it "defaults to not published" do
    subject { Factory(:subject, :published => nil) }
    subject.published.should be_false
  end

  it "responds to publish!" do
    should respond_to :publish!
  end

  it "responds to unpublish!" do
    should respond_to :unpublish!
  end

  it "publishes itself" do
    subject = Factory(:subject, :owner => @user,
                      :space => @space, :published => false)
    subject.publish!
    subject.should be_published
  end

  it "unpublishes itself and removes all enrollments" do
    users = (1..4).collect { Factory(:user) }
    subject = Factory(:subject, :owner => @user,
                      :space => @space, :published => true)
    users.each { |u| subject.enroll(u) }

    subject.unpublish!
    subject.should_not be_published
    subject.enrollments.reload
    subject.enrollments.size.should == 1
    subject.enrollments.first.user.should == @user
  end

  it "responds to enroll" do
    should respond_to :enroll
  end

  it "responds to unenroll" do
    should respond_to :unenroll
  end

  context "enrollments" do
    before :each do
      @enrolled_user = Factory(:user)
    end

    it "enrolls an user" do
      expect {
        subject.enroll(@enrolled_user)
      }.should change(subject.enrollments, :count).by(1)
    end

    it "enrolls an user with a given role" do
      subject.enroll(@enrolled_user, Role[:teacher]).should be_true
      subject.enrollments.last.role_id.should == Role[:teacher].id
    end

    it "unenrolls an user" do
      enrollment = Factory(:enrollment, :user => @enrolled_user,
                           :subject => subject)

      expect {
        subject.unenroll(@enrolled_user)
      }.should change(subject.enrollments, :count).by(-1)
    end
  end

  context "lectures" do
    it "changes lectures order" do
      lectures = (1..4).collect { Factory(:lecture)}
      subject = Factory(:subject, :owner => @user,
                        :space => @space, :lectures => lectures)
      lectures_ordered = ["#{lectures[1].id}-lecture", "#{lectures[0].id}-lecture",
        "#{lectures[3].id}-lecture", "#{lectures[2].id}-lecture"]
      subject.change_lectures_order!(lectures_ordered)
      subject.reload.lectures.should == [lectures[1], lectures[0],
                                    lectures[3], lectures[2]]
    end
  end

end

require 'spec_helper'

describe Subject do
  subject { Factory(:subject) }

  it { should validate_presence_of :title }
  #FIXME falhando por problema de tradução
  xit { should ensure_length_of(:description).is_at_least(30).is_at_most(200) }

  it { should belong_to :space }
  it { should belong_to :owner }
  it { should have_many :lectures }
  it { should have_many(:graduated_members).through :enrollments }
  it { should have_many(:members).through :enrollments }

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
      enrollment = Factory(:enrollment, :user_id => @user, :subject_id => subject)

      expect {
        subject.unenroll(@user)
      }.should_not change(subject.enrollments, :count)
    end
  end
end

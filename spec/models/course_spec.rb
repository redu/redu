require 'spec_helper'

describe Course do
  subject { Factory(:course) }

  it { should belong_to :environment }
  it { should belong_to :owner }

  it { should have_many(:spaces).dependent :destroy }
  it { should have_many(:invitations).dependent :destroy }
  it { should have_many(:user_course_associations).dependent :destroy }
  it { should have_many(:users).through :user_course_associations }
  it { should have_many(:approved_users).through :user_course_associations }

  it { should have_and_belong_to_many :audiences }

  it { should validate_presence_of :name }
  it { should validate_presence_of :path }
  #FIXME Não funciona por problemas de tradução (ver bug #17)
  xit { should validate_uniqueness_of(:name).scoped_to :environment_id}
  xit { should validate_uniqueness_of(:path).scoped_to :environment_id}

  context "finders" do
    it "retrieves approved users" do
      users = 4.times.inject([]) { |res, i| res << Factory(:user) }
      subject.users << users
      users[1].user_course_associations.last.approve!
      users[3].user_course_associations.last.approve!

      subject.approved_users.should == [users[1], users[3]]
    end

    it "retrieves all courses of an specified environment" do
      environment = Factory(:environment)
      course2 = Factory(:course)
      course3 = Factory(:course)
      subject.environment = environment
      course2.environment = environment
      subject.save
      course2.save

      Course.of_environment(environment).should == [course2, subject]
    end

    it "retrieves a course by its path" do
      Course.find(subject.path).should == subject
    end
  end

  it "generates a permalink" do
    APP_URL.should_not be_nil
    environment = Factory(:environment)
    subject.environment = environment
    subject.permalink.should include(subject.path)
    subject.permalink.should include(environment.path)
  end

  it "verifies if it can be published" do
    subject.can_be_published?.should == false
    space = Factory(:space, :course => subject)
    subject.can_be_published?.should == true
  end

  it "changes a user role" do
    user = Factory(:user)
    subject.users << user
    subject.save

    expect {
      subject.change_role(user, Role[:tutor])
    }.should change {
      subject.user_course_associations.last.role }.to(Role[:tutor])

  end
  it "choose another path if the specified already exists" do
    @course = Factory.build(:course, :path => subject.path)
    @course.verify_path!(subject.environment)
    @course.path.should_not == subject.path
  end
end

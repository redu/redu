require 'spec_helper'

describe Environment do
  subject { Factory(:environment) }

  it { should have_many(:courses).dependent(:destroy) }
  it { should have_many(:user_environment_associations).dependent(:destroy) }
  it { should have_many(:bulletins).dependent(:destroy) }
  it { should have_many(:users).through(:user_environment_associations)}
  it { should have_many(:administrators).through(:user_environment_associations)}
  it { should have_many(:users).through(:user_environment_associations)}
  it { should have_many(:users).through(:user_environment_associations)}
  it { should belong_to(:owner)}
  it { should have_one(:partner).through(:partner_environment_association) }
  it { should have_one(:partner_environment_association) }
  it { should accept_nested_attributes_for :courses }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:path) }
  it { should validate_presence_of(:initials) }
  xit { should validate_uniqueness_of(:name) }
  xit { should validate_uniqueness_of(:path) }
  it { should validate_format_of(:path).with("teste-medio1")}
  it { should ensure_length_of(:name).is_at_most 40 }
  it { should ensure_length_of(:initials).is_at_most(10)}
  it { should ensure_length_of(:description).is_at_most(400)}

  it { should_not allow_mass_assignment_of(:owner)}
  it { should_not allow_mass_assignment_of(:published)}

  context "validations" do
    it "ensure format for path: doesn't accept space" do
      subject.path = "teste medio"
      subject.should_not be_valid
      subject.errors[:path].should_not be_empty
    end

    it "ensure format for path: doesn't accept '?'" do
      subject.path = "teste-medio?"
      subject.should_not be_valid
      subject.errors[:path].should_not be_empty
    end

    it "doesnt accept ." do
      subject.path = "www.redu.com.br"
      subject.should_not be_valid
      subject.errors[:path].should_not be_empty
    end
  end

  context "finders" do
    it "retrieves a Environment by its path" do
      Environment.find(subject.path).should == subject
    end

    it "retrieves all members" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      Factory(:user_environment_association, :user => users[0],
              :environment => subject, :role => :environment_admin)
      Factory(:user_environment_association, :user => users[1],
              :environment => subject, :role => :environment_admin)
      Factory(:user_environment_association, :user => users[2],
              :environment => subject, :role => :teacher)
      Factory(:user_environment_association, :user => users[3],
              :environment => subject, :role => :tutor)
      Factory(:user_environment_association, :user => users[4],
              :environment => subject, :role => :member)
      subject.users.to_set.
        should == (users << subject.owner).to_set
    end

    it "retrieves all administrators" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      Factory(:user_environment_association, :user => users[0],
              :environment => subject, :role => :environment_admin)
      Factory(:user_environment_association, :user => users[1],
              :environment => subject, :role => :environment_admin)
      Factory(:user_environment_association, :user => users[2],
              :environment => subject, :role => :teacher)
      Factory(:user_environment_association, :user => users[3],
              :environment => subject, :role => :tutor)
      Factory(:user_environment_association, :user => users[4],
              :environment => subject, :role => :member)
      subject.administrators.to_set.
        should == [users[0], users[1], subject.owner].to_set
    end

    it "retrieves all teachers" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      Factory(:user_environment_association, :user => users[0],
              :environment => subject, :role => :teacher)
      Factory(:user_environment_association, :user => users[1],
              :environment => subject, :role => :teacher)
      Factory(:user_environment_association, :user => users[2],
              :environment => subject, :role => :teacher)
      Factory(:user_environment_association, :user => users[3],
              :environment => subject, :role => :tutor)
      Factory(:user_environment_association, :user => users[4],
              :environment => subject, :role => :member)
      subject.teachers.to_set.
        should == [users[0], users[1], users[2]].to_set
    end

    it "retrieves all tutors" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      Factory(:user_environment_association, :user => users[0],
              :environment => subject, :role => :tutor)
      Factory(:user_environment_association, :user => users[1],
              :environment => subject, :role => :tutor)
      Factory(:user_environment_association, :user => users[2],
              :environment => subject, :role => :teacher)
      Factory(:user_environment_association, :user => users[3],
              :environment => subject, :role => :member)
      Factory(:user_environment_association, :user => users[4],
              :environment => subject, :role => :member)
      subject.tutors.to_set.
        should == [users[0], users[1]].to_set
    end
  end

  it "generates a permalink" do
    Redu::Application.config.url.should_not be_nil
    subject.permalink.should include(subject.path)
  end

  it "changes a user role" do
    user = Factory(:user)
    subject.users << user
    subject.save

    expect {
      subject.change_role(user, Role[:environment_admin])
    }.should change {
      subject.user_environment_associations.last.role }.to(Role[:environment_admin])
  end

  it "choose another path if the specified already exists" do
    @environment = Factory.build(:environment, :path => subject.path)
    @environment.verify_path!
    @environment.path.should_not == subject.path
  end
  context "callbacks" do
    it "creates an environment association" do
      subject.users.last.should == subject.owner
    end

    it "creates an approved course association with the first course" do
      user = Factory(:user)
      subject = Factory(:environment, :owner => user,
                        :courses => [Factory(:course, :owner => user)])
      subject.courses.first.owner.should == subject.owner
      subject.courses.first.users.should include(subject.owner)
      user.user_course_associations.last.state.should == 'approved'
    end
  end
end

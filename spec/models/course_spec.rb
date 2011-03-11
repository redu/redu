require 'spec_helper'

describe Course do

  before(:each) do
    @environment = Factory(:environment)
    @user = Factory(:user)
    UserEnvironmentAssociation.create(:user => @user,
                                      :environment => @environment,
                                      :role => Role[:environment_admin])
  end

  subject { Factory(:course, :owner => @user, :environment => @environment) }

  it { should belong_to :environment }
  it { should belong_to :owner }

  it { should have_many(:spaces).dependent :destroy }
  it { should have_many(:invitations).dependent :destroy }
  it { should have_many(:user_course_associations).dependent :destroy }
  it { should have_many(:users).through :user_course_associations }
  it { should have_many(:approved_users).through :user_course_associations }
  it { should have_many(:administrators).through :user_course_associations }
  it { should have_many(:teachers).through :user_course_associations }
  it { should have_many(:tutors).through :user_course_associations }
  it { should have_many(:students).through :user_course_associations }

  it { should have_and_belong_to_many :audiences }
  it { should have_one(:quota).dependent(:destroy) }
  it { should have_one(:plan) }


  it { should validate_presence_of :name }
  it { should validate_presence_of :path }
  #FIXME Não funciona por problemas de tradução (ver bug #17)
  xit { should validate_uniqueness_of(:name).scoped_to :environment_id}
  xit { should validate_uniqueness_of(:path).scoped_to :environment_id}
  it { should ensure_length_of(:name).is_at_most 60 }
  it { should ensure_length_of(:description).is_at_most 250 }

  it { should_not allow_mass_assignment_of :owner }
  it { should_not allow_mass_assignment_of :published }
  it { should_not allow_mass_assignment_of :environment }

  context "validations" do
    it "ensure tags has a length of at most 110"  do
      tags = (1..100).collect { Factory(:tag) }
      subject = Factory.build(:course, :tags => tags)
      subject.should_not be_valid
      subject.errors.on(:tags).should_not be_empty
    end
  end

  context "callbacks" do
    it "creates an approved association with its owner" do
      subject.owner.should == subject.users.last
      subject.owner.user_course_associations.last.state.should == 'approved'
    end

    it "creates a course association with all environment admins if it already has an environment" do
      e = Factory(:environment)
      users = (1..4).collect { Factory(:user) }
      e.users << [users[0], users[1], users[2]]

      users[0].user_environment_associations.last.update_attribute(:role, Role[:environment_admin])
      users[1].user_environment_associations.last.update_attribute(:role, Role[:environment_admin])

      c = Factory(:course, :owner => users[1], :environment => e)
      c.users.to_set.should == e.administrators.to_set
    end

    it "does NOT create a course association with all environment admins if it does NOT have an environment" do
      expect {
        subject = Factory(:course, :environment => nil)
      }.should_not change(UserCourseAssociation, :count)
    end
  end

  context "finders" do
    it "retrieves all courses of an specified environment" do
      course2 = Factory(:course, :environment => subject.environment)
      course3 = Factory(:course)

      Course.of_environment(subject.environment).to_set.
        should == [course2, subject].to_set
    end

    it "retrieves a course by its path" do
      Course.find(subject.path).should == subject
    end

    it "retrieves all approved users" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      subject.join(users[0], Role[:environment_admin])
      subject.join(users[1], Role[:environment_admin])
      subject.join(users[2], Role[:teacher])
      subject.join(users[3], Role[:tutor])
      subject.join(users[4], Role[:member])

      subject.users.to_set.
        should == (users << subject.owner << subject.environment.owner).to_set
    end

    it "retrieves all administrators" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      subject.join(users[0], Role[:environment_admin])
      subject.join(users[1], Role[:environment_admin])
      subject.join(users[2], Role[:teacher])
      subject.join(users[3], Role[:tutor])
      subject.join(users[4], Role[:member])
      subject.administrators.to_set.
        should == [users[0], users[1], subject.owner, subject.environment.owner].to_set
    end

    it "retrieves all teachers" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      Factory(:user_course_association, :user => users[0],
              :course => subject, :role => :environment_admin)
      Factory(:user_course_association, :user => users[1],
              :course => subject, :role => :teacher)
      Factory(:user_course_association, :user => users[2],
              :course => subject, :role => :teacher)
      Factory(:user_course_association, :user => users[3],
              :course => subject, :role => :tutor)
      Factory(:user_course_association, :user => users[4],
              :course => subject, :role => :member)
      subject.user_course_associations.each do |assoc|
        assoc.approve!
      end

      subject.teachers.to_set.
        should == [users[1], users[2]].to_set
    end

    it "retrieves all tutors" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      Factory(:user_course_association, :user => users[0],
              :course => subject, :role => :environment_admin)
      Factory(:user_course_association, :user => users[1],
              :course => subject, :role => :teacher)
      Factory(:user_course_association, :user => users[2],
              :course => subject, :role => :tutor)
      Factory(:user_course_association, :user => users[3],
              :course => subject, :role => :tutor)
      Factory(:user_course_association, :user => users[4],
              :course => subject, :role => :member)
      subject.user_course_associations.each do |assoc|
        assoc.approve!
      end

      subject.tutors.to_set.
        should == [users[2], users[3]].to_set
    end

    it "retrieves all students" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      Factory(:user_course_association, :user => users[0],
              :course => subject, :role => :environment_admin)
      Factory(:user_course_association, :user => users[1],
              :course => subject, :role => :teacher)
      Factory(:user_course_association, :user => users[2],
              :course => subject, :role => :tutor)
      Factory(:user_course_association, :user => users[3],
              :course => subject, :role => :member)
      Factory(:user_course_association, :user => users[4],
              :course => subject, :role => :member)
      subject.user_course_associations.each do |assoc|
        assoc.approve!
      end

      subject.students.to_set.
        should == [users[3], users[4]].to_set
    end

    it "retrieves all courses in one of specified categories" do
      audiences = (1..4).collect { Factory(:audience) }
      courses = (1..4).collect { Factory(:course) }

      courses[0].audiences << audiences[0] << audiences[1] << audiences[2]
      courses[1].audiences << audiences[0]
      courses[2].audiences << audiences[2]
      courses[3].audiences << audiences[3]

      Course.with_audiences([audiences[0].id, audiences[2].id]).
        should == [courses[0], courses[1], courses[2]]
    end

    context "retrieves all courses where the specified user" do
      before do
        @user = Factory(:user)
        @courses = (0..5).collect { Factory(:course) }
        @courses[0].join @user
        @courses[1].join @user
        @courses[2].join @user, Role[:tutor]
        @courses[3].join @user, Role[:teacher]
        @courses[4].join @user, Role[:environment_admin]

        @courses[5].join Factory(:user)
        @courses[5].join Factory(:user), Role[:tutor]
        @courses[5].join Factory(:user), Role[:teacher]
        @courses[5].join Factory(:user), Role[:environment_admin]
      end

      it "is a administrator" do
        Course.user_behave_as_administrator(@user).should == [@courses[4]]
      end
      it "is a teacher" do
        Course.user_behave_as_teacher(@user).should == [@courses[3]]
      end
      it "is a tutor" do
        Course.user_behave_as_tutor(@user).should == [@courses[2]]
      end
      it "is a student" do
        Course.user_behave_as_student(@user).should == @courses[0..1]
      end
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

  it "accepts a user (join)" do
    space = Factory(:space, :course => subject)
    user = Factory(:user)
    subject.join(user)
    subject.users.should include(user)
    space.users.should include(user)
  end

  it "removes a user (unjoin)" do
    space = Factory(:space, :course => subject)
    user = Factory(:user)
    subject.join(user)
    subject.unjoin(user)
    subject.users.should_not include(user)
    space.users.should_not include(user)
  end

  it "verifies if the user is waiting for approval" do
    user = Factory(:user)
    subject.update_attribute(:subscription_type, 2)
    subject.join(user)

    subject.waiting_approval?(user).should be_true
  end

  it "creates hierarchy associations for a specified user" do
    space = Factory(:space, :course => subject)
    subject.spaces << space
    user = Factory(:user)

    subject.create_hierarchy_associations(user)
    user.user_environment_associations.last.environment.
      should == subject.environment
    user.user_space_associations.last.space.should == space
  end

  it "creates hierarchy associations for a specified user with a given role" do
    space = Factory(:space, :course => subject)
    subject.spaces << space
    user = Factory(:user)

    subject.create_hierarchy_associations(user, Role[:tutor])
    user.user_environment_associations.last.environment.
      should == subject.environment
    user.user_space_associations.last.space.should == space
    user.user_environment_associations.last.role.should == Role[:tutor]
    user.user_space_associations.last.role.should == Role[:tutor]
  end
end

require 'spec_helper'

describe Environment do
  subject { Factory(:environment) }

  it { should have_many(:courses).dependent(:destroy) }
  it { should have_many(:user_environment_associations).dependent(:destroy) }
  it { should have_many(:users).through(:user_environment_associations)}
  it { should have_many(:administrators).through(:user_environment_associations)}
  it { should have_many(:users).through(:user_environment_associations)}
  it { should have_many(:users).through(:user_environment_associations)}
  it { should have_many(:plans) }
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

    it "retrieves all students (role member)" do
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
      subject.students.to_set.
        should == [users[3], users[4]].to_set
    end
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

  it { should respond_to :plan }

  it "should return actual plan" do
    plan = Factory(:active_package_plan, :billable => subject, :current => false)
    plan2 = Factory(:active_package_plan, :billable => subject)

    subject.plan.should == plan2
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

  it "doesnt accept ." do
    subject.path = "www.redu.com.br"
    subject.should_not be_valid
    subject.errors[:path].should_not be_empty
  end

  it "by default is published" do
    subject.should be_published
  end

  context "behaves like a billable" do
    before do
      users = 4.times.collect { Factory(:user) }

      Factory(:active_package_plan, :billable => subject, :user => subject.owner,
              :members_limit => 10)

      Factory(:quota, :billable => subject)
      course = Factory(:course, :environment => subject, :quota => nil)
      course.join(users[0], Role[:environment_admin])
      course.join(users[1], Role[:environment_admin])
      course.join(users[2], Role[:teacher])
      course.join(users[3], Role[:tutor])
    end

    it_should_behave_like "a billable" do
      let(:billable) { subject }
    end

    context "when verifying members limit and plan is on environment" do
      before do
        subject.courses = (1..2).collect { Factory(:course, :environment => nil) }
        # Sem moderação
        subject.courses.each do |c|
          c.subscription_type = 1
          (1..5).each { c.join(Factory(:user)) }
        end
      end

      context "and plan has members limit" do
        before do
          plan = Plan.from_preset(:free)
          plan.user = subject.owner
          plan.members_limit = 30
          subject.plan = plan
        end

        it "should permit entry" do
          subject.can_add_entry?.should be_true
        end

        it "should NOT permit entry" do
          (1..15).each { subject.courses.first.join(Factory(:user)) }
          subject.can_add_entry?.should be_false
        end
      end

      context "and plan dones NOT have members limit" do
        before do
          plan = Plan.from_preset(:free, "LicensedPlan")
          plan.user = subject.owner
          subject.plan = plan
        end

        it "should permit entry" do
          subject.can_add_entry?.should be_true
        end

        it "should permit entry" do
          (1..15).each { subject.courses.first.join(Factory(:user)) }
          subject.can_add_entry?.should be_true
        end
      end
    end

    context "when destroying" do
      let(:subject) { Factory(:environment) }
      context "with an associated plan" do
        before do
          subject.reload
          subject.plans = []
          subject.courses = []
          @plan = Factory(:active_package_plan, :billable => subject)
        end

        it "should persist environment attributes" do
          @plan.billable.audit_billable_and_destroy
          @plan.reload.billable_audit["name"].should == subject.name
          @plan.reload.billable_audit["path"].should == subject.path
        end

        it "should persist courses" do
          courses = (1..3).collect { Factory(:course, :environment => subject) }

          subject.audit_billable_and_destroy

          @plan.reload.billable_audit[:courses].should_not be_nil
          @plan.reload.billable_audit[:courses].collect { |c| c["name"] }.to_set.
            should == courses.collect {|c| c.name }.to_set
        end
      end

      context "withdout an associated plan" do
        it "should only destroy itself" do
          expect {
            subject.audit_billable_and_destroy
          }.should_not raise_error
        end
      end
    end
  end
end

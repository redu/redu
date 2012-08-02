require 'spec_helper'

describe Course do

  before(:each) do
    @environment_owner = Factory(:user)
    @environment = Factory(:environment, :owner => @environment_owner)
  end

  subject { Factory(:course, :owner => @environment_owner,
                    :environment => @environment) }

  it { should belong_to :environment }
  it { should belong_to :owner }

  it { should have_many(:spaces).dependent :destroy }
  it { should have_many(:user_course_associations).dependent :destroy }
  it { should have_many(:user_course_invitations).dependent :destroy }
  it { should have_many(:users).through :user_course_associations }
  it { should have_many(:approved_users).through :user_course_associations }
  it { should have_many(:pending_users).through :user_course_associations }
  it { should have_many(:administrators).through :user_course_associations }
  it { should have_many(:teachers).through :user_course_associations }
  it { should have_many(:tutors).through :user_course_associations }
  it { should have_many(:students).through :user_course_associations }
  it { should have_many(:teachers_and_tutors).through :user_course_associations }

  it { should have_and_belong_to_many :audiences }
  it { should have_one(:quota).dependent(:destroy) }

  it { should have_many :logs }
  it { should have_many :statuses }

  it { should validate_presence_of :name }
  it { should validate_presence_of :path }
  #FIXME Não funciona por problemas de tradução (ver bug #17)
  xit { should validate_uniqueness_of(:name).scoped_to :environment_id}
  xit { should validate_uniqueness_of(:path).scoped_to :environment_id}
  it { should ensure_length_of(:name).is_at_most 60 }
  it { should ensure_length_of(:description).is_at_most 250 }
  it { should validate_format_of(:path).with("teste-medio")}

  it { should_not allow_mass_assignment_of :owner }
  it { should_not allow_mass_assignment_of :published }
  it { should_not allow_mass_assignment_of :environment }

  it { Course.new.should respond_to(:notify).with(1).argument}
  it { Course.new.should respond_to(:has_basic_content)}

  context "validations" do
    it "ensure format for path: doesn't accept no ascii" do
      subject.path = "teste-médio"
      subject.should_not be_valid
      subject.errors[:path].should_not be_empty
    end

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
      subject.subscription_type = 2 # Com moderação
      subject.save

      subject.join(users[0], Role[:environment_admin])
      subject.join(users[1], Role[:environment_admin])
      subject.join(users[2], Role[:teacher])
      subject.join(users[3], Role[:tutor])
      subject.join(users[4], Role[:member])

      users[0..2].collect { |u| u.user_course_associations.last.approve! }

      subject.approved_users.to_set.
        should == (users[0..2] << subject.owner <<
          subject.environment.owner).to_set
    end

    it "retrieves all pending users" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      subject.subscription_type = 2 # Com moderação
      subject.save

      subject.join(users[0], Role[:environment_admin])
      subject.join(users[1], Role[:environment_admin])
      subject.join(users[2], Role[:teacher])
      subject.join(users[3], Role[:tutor])
      subject.join(users[4], Role[:member])

      users[0..2].collect { |u| u.user_course_associations.last.approve! }

      subject.pending_users.should == users[3..4]
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
      subject.user_course_associations.waiting.each do |assoc|
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
      subject.user_course_associations.waiting.each do |assoc|
        assoc.approve!
      end

      subject.tutors.to_set.
        should == [users[2], users[3]].to_set
    end

    it "retrieves all teachers and tutors" do
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
      subject.user_course_associations.waiting.each do |assoc|
        assoc.approve!
      end

      subject.teachers_and_tutors.to_set.
        should == [users[1], users[2], users[3]].to_set
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
      subject.user_course_associations.waiting.each do |assoc|
        assoc.approve!
      end

      subject.students.to_set.
        should == [users[3], users[4]].to_set
    end

    it "retrieves new users from 1 week ago" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      Factory(:user_course_association, :user => users[0],
              :course => subject, :role => :environment_admin,
              :created_at => 2.weeks.ago,
              :updated_at => 2.weeks.ago)
      Factory(:user_course_association, :user => users[1],
              :course => subject, :role => :teacher,
              :updated_at => 2.weeks.ago)
      Factory(:user_course_association, :user => users[2],
              :course => subject, :role => :tutor,
              :updated_at => 2.weeks.ago)
      Factory(:user_course_association, :user => users[3],
              :course => subject, :role => :member,
              :updated_at => 2.weeks.ago)
      Factory(:user_course_association, :user => users[4],
              :course => subject, :role => :member,
              :updated_at => 2.weeks.ago)

      subject.user_course_associations.update_all("state = 'approved'")

      subject.new_members.to_set.
        should == [@environment_owner].to_set
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
        @courses = (0..6).collect { Factory(:course) }
        @courses[0].join @user
        @courses[1].join @user
        @courses[2].join @user, Role[:tutor]
        @courses[3].join @user, Role[:teacher]
        @courses[4].join @user, Role[:environment_admin]
        UserCourseAssociation.create(
          :course_id => @courses[6].id, :user_id => @user.id,
          :role => Role[:member])


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

  it "changes a user role" do
    user = Factory(:user)
    subject.users << user
    subject.save

    expect {
      subject.change_role(user, Role[:tutor])
    }.should change {
      subject.user_course_associations.last.role }.to(Role[:tutor])

  end

  context "when joining an user" do
    before do
      @space = Factory(:space, :course => subject)
      @subj = Factory(:subject, :space => @space,
                              :owner => subject.owner,
                              :finalized => true)
      @user = Factory(:user)
      subject.reload
    end

    context "without a role" do
      before do
        subject.join(@user)
      end

      it "creates environment association" do
        assoc = @user.get_association_with(@environment)
        assoc.should_not be_nil
        assoc.role.should == Role[:member]
      end

      it "creates course association" do
        assoc = @user.get_association_with(subject)
        assoc.should_not be_nil
        assoc.role.should == Role[:member]
      end

      it "creates space association" do
        assoc = @user.get_association_with(@space)
        assoc.should_not be_nil
        assoc.role.should == Role[:member]
      end

      it "enrolls the user" do
        assoc = @user.get_association_with(@subj)
        assoc.should_not be_nil
        assoc.role.should == Role[:member]
      end
    end

    context "whith a role" do
      before do
        subject.join(@user, Role[:environment_admin])
      end

      it "creates environment association" do
        assoc = @user.get_association_with(@environment)
        assoc.should_not be_nil
        assoc.role.should == Role[:environment_admin]
      end

      it "creates course association" do
        assoc = @user.get_association_with(subject)
        assoc.should_not be_nil
        assoc.role.should == Role[:environment_admin]
      end

      it "creates space association" do
        assoc = @user.get_association_with(@space)
        assoc.should_not be_nil
        assoc.role.should == Role[:environment_admin]
      end

      it "enrolls the user" do
        assoc = @user.get_association_with(@subj)
        assoc.should_not be_nil
        assoc.role.should == Role[:environment_admin]
      end
    end

    context "with user invited" do
      before do
        subject.invite(@user)
        @user.reload
      end

      it "should approve and create all hierarchy" do
        subject.join(@user)
        assoc = @user.get_association_with(subject)
        assoc.state.should == "approved"
      end
    end

    context "when plan is licensed" do
      before do
        @plan = Factory(:active_licensed_plan, :billable => @environment,
                        :user => subject.owner)
        @plan.create_invoice_and_setup
        @environment.create_quota
        @environment.reload
      end

      it "should create a license" do
        @user= Factory(:user)
        expect {
          subject.join(@user)
        }.should change(License, :count).by(1)
      end
    end
  end

  context "when force joining a user" do
    before  do
      @user = Factory(:user)
      @moderated_course = Factory(:course,  :owner => @environment_owner,
        :environment => @environment, :subscription_type => 0)
    end

    it "should join! uninvited user(subscription_type 0)" do
      @moderated_course.join!(@user)
      @user.get_association_with(@moderated_course).should be_approved
    end

    it "should join! on open courses(subscription_type 1)" do
      subject.join!(@user)
      @user.get_association_with(subject).should be_approved
    end

    it "should join! invited user (subscription_type 0)" do
      @moderated_course.join(@user)
      @user.get_association_with(@moderated_course).invite!
      @moderated_course.join!(@user)
      @user.get_association_with(@moderated_course).should be_approved
    end
  end

  context "removes a user (unjoin)" do
    before do
      @plan = Factory(:active_licensed_plan, :billable => @environment)
      @plan.create_invoice_and_setup
      @environment.create_quota
      @environment.reload
      @space = Factory(:space, :course => subject)
      @space_2 = Factory(:space, :course => subject)
      @sub = Factory(:subject, :space => @space, :owner => subject.owner,
                     :finalized => true)
      @sub_2 = Factory(:subject, :space => @space_2, :owner => subject.owner,
                     :finalized => true)
      @user = Factory(:user)
      subject.join @user
      subject.reload
    end

    it "removes a user from itself" do
      subject.unjoin @user
      subject.users.should_not include(@user)
    end

    it "removes a user from all spaces" do
      subject.unjoin @user
      @space.users.should_not include(@user)
      @space_2.users.should_not include(@user)
    end

    it "removes a user from all enrolled subjects" do
      subject.unjoin @user
      @sub.members.should_not include(@user)
      @sub_2.members.should_not include(@user)
    end

    context "when plan is licensed" do
      it "should set the period end of a license that" do
        subject.unjoin @user
        subject.environment.plan.invoice.licenses.last.
          period_end.should_not be_nil
      end
    end

    context "when user is enrolled with just one course" do
      it "removes the user from the environment" do
        expect {
          subject.unjoin @user
        }.should change(UserEnvironmentAssociation, :count).by(-1)
        @environment.users.should_not include(@user)
      end
    end

    context "when user is enrolled with more than one course" do
      before do
        @other_course = Factory(:course, :environment => @environment)
        @other_course.join @user
      end

      it "let the user as a member of the environment"  do
        expect {
          subject.unjoin @user
        }.should_not change(UserEnvironmentAssociation, :count)
        @environment.users.should include(@user)
      end
    end

    context 'when the user is with pending moderation' do
      before do
        @user_pending = Factory(:user)
        subject.update_attribute(:subscription_type, 2) # Com Moderação
        subject.join @user_pending
      end

      it 'dont raise an error' do
        expect {
          subject.unjoin @user_pending
        }.should_not raise_error
      end
    end
  end

  it "verifies if the user is waiting for approval" do
    user = Factory(:user)
    subject.update_attribute(:subscription_type, 2)
    subject.join(user)

    subject.waiting_approval?(user).should be_true
  end

  it "verifies if the user has been rejected" do
    user = Factory(:user)
    subject.update_attribute(:subscription_type, 2)
    subject.join(user)
    user.user_course_associations.last.reject!

    subject.rejected_participation?(user).should be_true
  end

  it "verifies if the course is waiting for user approval" do
    user = Factory(:user)
    subject.update_attribute(:subscription_type, 2)
    subject.invite(user)

    subject.waiting_user_approval?(user).should be_true
  end

  context "when creating hierarchy associations" do
    before do
      @space = Factory(:space, :course => subject)
      subject.spaces << @space
      @user = Factory(:user)
    end

    it "creates hierarchy associations for a specified user" do
      subject.create_hierarchy_associations(@user)
      @user.user_environment_associations.last.environment.
        should == subject.environment
      @user.user_space_associations.last.space.should == @space
    end

    it "creates hierarchy associations for a specified user with a given role" do
      subject.create_hierarchy_associations(@user, Role[:tutor])
      @user.user_environment_associations.last.environment.
        should == subject.environment
      @user.user_space_associations.last.space.should == @space
      @user.user_environment_associations.last.role.should == Role[:tutor]
      @user.user_space_associations.last.role.should == Role[:tutor]
    end

    it "should not double create environment association" do
      expect {
        2.times do
          subject.create_hierarchy_associations(@user, Role[:tutor])
        end
      }.should change(UserEnvironmentAssociation, :count).by(1)
    end

    it "should not double create space association" do
      expect {
        2.times do
          subject.create_hierarchy_associations(@user, Role[:tutor])
        end
      }.should change(UserSpaceAssociation, :count).by(1)
    end
  end

  context "when inviting an user" do

    it "returns the association" do
      @incoming_user = Factory(:user)
      assoc = subject.invite(@incoming_user)
      assoc.should == @incoming_user.get_association_with(subject)
    end

    it "sets up the member Role as default" do
      @incoming_user = Factory(:user)
      assoc = subject.invite(@incoming_user)
      assoc.role.should == Role[:member]
    end

    context "when the user is not associated at all" do
      before do
        @incoming_user = Factory(:user)
        subject.invite(@incoming_user)
      end

      it "creates an association" do
        assoc = subject.user_course_associations.last
        assoc.user.should == @incoming_user
      end

      it "invites the user" do
        assoc = subject.user_course_associations.last
        assoc.should be_invited
      end
    end

    context "when the user is in moderation" do
      before do
        subject.update_attribute(:subscription_type, 0)

        @incoming_user = Factory(:user)
        subject.join(@incoming_user)
      end

      it "does not create a new association" do
        expect {
          subject.invite(@incoming_user)
        }.should_not change(UserCourseAssociation, :count)
      end

      it "changes his state to approved" do
          subject.invite(@incoming_user)
          @incoming_user.reload.get_association_with(subject).should be_approved
      end
    end

    context "when the user is already invited" do
      before do
        @incoming_user = Factory(:user)
        subject.invite(@incoming_user)
      end

      it "does not create a new association" do
        expect {
          subject.invite(@incoming_user)
        }.should_not change(UserCourseAssociation, :count)
      end
    end

    context "when the user is already approved" do
      before do
        @already_member = Factory(:user)
        subject.update_attribute(:subscription_type, 1)
        subject.join(@already_member)
      end

      it "does not change his state" do
        expect {
          subject.invite(@already_member)
        }.should_not change {
          @already_member.get_association_with(subject).state
        }
      end
    end

    context "and it is already invited" do
      before do
        UserNotifier.delivery_method = :test
        UserNotifier.perform_deliveries = true
        UserNotifier.deliveries = []

        @already_invited = Factory(:user)
        @invitation = subject.invite @already_invited
      end

      it "does NOT change his state" do
        expect {
          subject.invite(@already_invited)
        }.should_not change {
          @already_invited.get_association_with(subject).state
        }
      end

      it "returns the same invitation" do
        invitation = subject.invite @already_invited
        invitation.should == @invitation
      end

      it "resends the e-mail invitation" do
        UserNotifier.deliveries = []

        invitation = subject.invite(@already_invited)
        UserNotifier.deliveries.should_not be_empty
        UserNotifier.deliveries.last.subject.should =~ /Você foi convidado para realizar um curso a distância/
      end
    end

    context "by email" do
      before do
        @not_registered_email = "email@example.com"
      end

      it "returns the invitation"  do
        assoc = subject.invite_by_email(@not_registered_email)
        assoc.should == subject.user_course_invitations.reload.last

        u = Factory(:user)
        assoc = subject.invite_by_email(u.email)
        assoc.should == subject.user_course_associations.reload.last
      end

      context "when the email is not registered on Redu at all" do
        it "creates an email invitation" do
          expect {
            subject.invite_by_email(@not_registered_email)
          }.should change(UserCourseInvitation, :count).by(1)
        end
      end

      context "when the email is already invited" do
        before do
            subject.invite_by_email(@not_registered_email)
        end

        it "does NOT create a new invitation" do
          expect {
            subject.invite_by_email(@not_registered_email)
          }.should_not change(UserCourseInvitation, :count)
        end
      end

      context "when the email is already registered on Redu" do
        before do
          @registered_user = Factory(:user)
        end

        it "does NOT create an e-mail invitation" do
          expect {
            subject.invite_by_email(@registered_user.email)
          }.should_not change(UserCourseInvitation, :count)
        end

        it "creates an association" do
          subject.reload
          expect {
            subject.invite_by_email(@registered_user.email)
          }.should change(UserCourseAssociation, :count).by(1)
        end
      end

      context "and it is already invited" do
        before do
          UserNotifier.delivery_method = :test
          UserNotifier.perform_deliveries = true
          UserNotifier.deliveries = []

          @email_already_invited = "email@example.com"
          @invitation = subject.invite_by_email @email_already_invited
        end

        it "does NOT change his state" do
          expect {
            subject.invite_by_email @email_already_invited
          }.should_not change {
            @invitation.reload.state
          }
        end

        it "returns the same invitation" do
          invitation = subject.invite_by_email @email_already_invited
          invitation.should == @invitation
        end

        it "resends the e-mail invitation" do
          UserNotifier.deliveries = []

          invitation = subject.invite_by_email @email_already_invited
          UserNotifier.deliveries.should_not be_empty
          UserNotifier.deliveries.last.subject.should =~ /Você foi convidado para realizar um curso a distância/
            UserNotifier.deliveries.last.body.should =~ /#{invitation.course.name}/
        end
      end
    end
  end

  context "when 3 or more people are enrolling to courses" do
    before do
      @users = 3.times.collect { Factory(:user) }

      ActiveRecord::Observer.with_observers(
        :user_course_association_observer,
        :log_observer,
        :status_observer) do
          @users.each { |user| subject.join(user) }
      end
      @course_compounds = CompoundLog.where(:statusable_id => subject.id)
    end

    it "should notify all users approved in course about compound log" do
      subject.approved_users.each do |user|
        StatusUserAssociation.where(
          :user_id => user.id,
          :status_id => @course_compounds.last.id).should_not be_empty
      end
    end
  end

  it "indicates if it invited users by email" do
    subject.invited?("email@example.com").should be_false

    subject.invite_by_email("email@example.com")
    subject.invited?("email@example.com").should be_true
  end

  it "doesnt accept ." do
    subject.path = "www.redu.com.br"
    subject.should_not be_valid
    subject.errors[:path].should_not be_empty
  end

  context "behaves like a billable" do
    before do
      users = 4.times.collect { Factory(:user) }

      Factory(:active_package_plan, :billable => subject, :user => subject.owner,
              :members_limit => 10)

      subject.join(users[0], Role[:environment_admin])
      subject.join(users[1], Role[:environment_admin])
      subject.join(users[2], Role[:teacher])
      subject.join(users[3], Role[:tutor])
    end

    it_should_behave_like "a billable" do
      let(:billable) { subject }
    end

    context "when verifying members limit and plan is on course" do
      before do
        # Sem moderação
        subject.subscription_type = 1
        (1..5).each { subject.join(Factory(:user)) }
      end

      context "and plan has members limit" do
        before do
          plan = Plan.from_preset(:free)
          plan.user = subject.owner
          plan.members_limit = 15
          subject.plan = plan
        end

        it "should permit entry" do
          subject.can_add_entry?.should be_true
        end

        it "should NOT permit entry" do
          (1..15).each { subject.join(Factory(:user)) }
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
          (1..15).each { subject.join(Factory(:user)) }
          subject.can_add_entry?.should be_true
        end
      end
    end

    context "when destroying" do
      let(:subject) { Factory(:course) }
      context "with an associated plan" do
        it "should persist environment attributes" do
          subject.plans = []
          plan = Factory(:active_package_plan, :billable => subject)

          subject.audit_billable_and_destroy
          plan.reload.billable_audit["name"].should == subject.name
          plan.reload.billable_audit["path"].should == subject.path
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

  context "with a space marked for destruction" do
    it "should destroy associated space" do
      subject.spaces << \
        Factory(:space, :owner => subject.owner, :course => subject,
                :destroy_soon => true)
      subject.spaces.reload
      expect {
        subject.destroy
      }.to change(Space, :count).by(-1)
    end
  end # context "with a space marked for destruction"

  # Testa a clonagem do curso de conteúdo básico do ensino médio
  #
  # A abordagem utilizada para os testes foi realizar testes para os elementos
  # da hierarquia que estão abaixo de Course:
  # * Space;
  # * Subject; e
  # * Lecture;
  # além de algumas verificações relacionadas às questões de exercícios para
  # lectures que possuem lectureable tipo Exercise.
  # Os testes foram esquematizados para assegurar as seguintes características
  # dos elementos colocados acima:
  # * número de elementos clonados é o mesmo de elementos originais;
  # * nome de elementos hierárquicos clonados é idêntico ao original; e
  # * elementos clonados e originais são diferentes (possuem id diferente);
  # além de assegurar que o id dos cursos (original e clone) são diferentes e
  # que o ambiente do curso original não é clonado.
  context "when cloning" do

    # FIXME
    # Atentar para o uso do before(:all)
    before(:all) do
      # Seta o curso original
      @jedi101 = Factory(:course, :environment => Factory(:environment),
                         :name => "Jedi101")
      5.times do |n|
        space = Factory(:space, :course => @jedi101)
        subject = Factory(:subject, :space => space)
        subject.update_attribute(:finalized, true)
        lecture = Factory(:lecture, :subject => subject)
        if n.even?
          exercise = Factory(:complete_exercise, :lecture => lecture)
          lecture.lectureable = exercise
        end
        subject.lectures << lecture
        space.subjects << subject
        @jedi101.spaces << space
      end

      # Cria o clone
      @sith101 = Factory.build(:course, :environment => Factory(:environment),
                            :name => "Sith101", :path => "sith101")
      @sith101.save
      @sith101.mimetize! @jedi101
    end

    after(:all) do
      User.all.each do |user|
        user.destroy
      end

      Environment.all.each do |environment|
        environment.destroy
      end

      Course.all.each do |course|
        course.destroy
      end

      Subject.all.each do |subject|
        subject.destroy
      end

      Exercise.all.each do |exercise|
        exercise.destroy
      end
    end

    it "should create a new course" do
      Course.find(@sith101.name).should_not be_nil
    end

    # ENVIRONMENT
    it "does not clone course environment" do
      @sith101.environment.should_not == @jedi101.environment
    end

    it "does not clone environment owner" do
      @sith101.environment.owner.should_not == @jedi101.environment.owner
    end

    # COURSE
    it "clone and original courses aren't the same" do
      @sith101.should_not == @jedi101
    end

    it "does not clone course owner" do
      @sith101.owner.should_not == @jedi101.owner
    end

    # SPACES
    it "number of original and cloned spaces is the same" do
      @sith101.spaces.each.count.should == @jedi101.spaces.each.count
    end

    it "clones all spaces from cloned course" do
      original_spaces_names = @jedi101.spaces.collect { |space| space.name }
      @sith101.spaces.each do |cloned_space|
        original_spaces_names.should include cloned_space.name
      end
    end

    it "does not clone space owner" do
      @sith101.spaces.first.owner.should_not == @jedi101.spaces.first.owner
    end

    # SUBJECTS
    it "number of original and cloned subjects is the same" do
      original_subjects = cloned_subjects = 0

      # Conta os módulos originais
      @jedi101.spaces.each do |space|
        original_subjects += space.subjects.count
      end

      # Conta os módulos clonados
      @sith101.spaces.each do |space|
        cloned_subjects += space.subjects.count
      end

      cloned_subjects.should == original_subjects
    end

    it "clones all subjects within spaces cloned from original course" do
      original_subjects_names = []
      cloned_subjects_names = []

      # Recupera os nomes de todos os módulos originais
      @jedi101.spaces.each do |original_space|
        original_subjects_names = original_space.subjects.collect { |sub| sub.name }
      end

      # Recupera os nomes de todos os módulos clonados
      @sith101.spaces.each do |cloned_space|
        cloned_subjects_names = cloned_space.subjects.collect { |sub| sub.name }
      end

      # Assegura que todo módulo original está contido no conjunto dos clonados
      original_subjects_names.each do |original_name|
        cloned_subjects_names.should include original_name
      end
    end

    it "cloned and original subjects aren't the same" do
      original_subjects = []
      cloned_subjects = []

      # Recupera todos os módulos originais
      @jedi101.spaces.each do |original_space|
        original_space.subjects.each do |subject|
          original_subjects << subject
        end
      end

      # Recupera todos os módulos clonados
      @sith101.spaces.each do |cloned_space|
        cloned_space.subjects.each do |subject|
          cloned_subjects << subject
        end
      end

      # Assegura que nenhum dos módulos originais está contido nos módulos clonados
      original_subjects.each do |original_subject|
        cloned_subjects.should_not include original_subject
      end
    end

    it "does not clone subject owner" do
      @sith101.spaces.first.subjects.first.owner.should_not == @jedi101.spaces.first.subjects.first.owner.should_not
    end

    # LECTURES
    it "number of original and cloned lectures is the same" do
      original = cloned = 0

      # Conta as aulas originais
      @jedi101.spaces.each do |space|
        original += space.lectures_count
      end

      # Conta as aulas clonadas
      @sith101.spaces.each do |space|
        cloned += space.lectures_count
      end

      cloned.should == original
    end

    it "clones all lectures within subjects cloned from original course" do
      original = []
      cloned = []

      # Recupera os nomes de todas as aulas originais
      @jedi101.spaces.each do |original_space|
        original_space.subjects.each do |subject|
          original = subject.lectures.collect { |lecture| lecture.name }
        end
      end

      # Recupera os nomes de todas as aulas clonadas
      @sith101.spaces.each do |cloned_space|
        cloned_space.subjects.each do |subject|
          cloned = subject.lectures.collect { |lecture| lecture.name }
        end
      end

      # Assegura que todos os nomes de aulas originais estão contidos no conjunto
      # dos nomes das aulas clonadas
      original.each do |original_name|
        cloned.should include original_name
      end
    end

    it "cloned and original lectures aren't the same" do
      original_lectures = []
      cloned_lectures = []

      # Recupera todas as aulas originais
      @jedi101.spaces.each do |original_space|
        original_space.subjects.each do |subject|
          subject.lectures.each do |lecture|
            original_lectures << lecture
          end
        end
      end

      # Recupera todas as aulas clonadas
      @sith101.spaces.each do |cloned_space|
        cloned_space.subjects.each do |subject|
          subject.lectures.each do |lecture|
            cloned_lectures << lecture
          end
        end
      end

      # Assegura que nenhuma das aulas originais está entre as aulas clonadas
      original_lectures.each do |original_lecture|
        cloned_lectures.should_not include original_lecture
      end
    end

    # QUESTIONS
    it "number of original and cloned questions within exercises is the same" do
      original = cloned = 0

      # Conta os exercícios originais
      @jedi101.spaces.each do |space|
        space.subjects.each do |subject|
          subject.lectures.each do |lecture|
            if lecture.lectureable.is_a?(Exercise)
              cloned += lecture.lectureable.questions.count
            end
          end
        end
      end

      # Conta os exercícios clonados
      @sith101.spaces.each do |space|
        space.subjects.each do |subject|
          subject.lectures.each do |lecture|
            if lecture.lectureable.is_a?(Exercise)
              original += lecture.lectureable.questions.count
            end
          end
        end
      end

      cloned.should == original
    end
  end # context "when cloning"
end

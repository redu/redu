require 'spec_helper'

describe User do
  subject { Factory(:user) }

  it { should have_many(:annotations).dependent(:destroy) }
  it { should have_many(:statuses).dependent(:destroy) }
  [:lectures, :exams, :exam_users, :questions, :favorites, :statuses,
    :subjects, :student_profiles, :subjects].each do |attr|
    it { should have_many attr }
    end

  it { should have_many :bulletins }

  it { should have_many(:exam_history).through :exam_users}
  it { should have_many(:invitations).dependent :destroy}
  it { should have_many(:enrollments).dependent :destroy}

  it { should have_one(:beta_key).dependent(:destroy)}

  it { should belong_to :metro_area }
  it { should belong_to :state }
  it { should belong_to :country }

  # Space
  it { should have_many(:spaces).through(:user_space_associations) }
  it { should have_many(:user_space_associations).dependent(:destroy) }
  it { should have_many(:spaces_owned) }

  # Course
  it { should have_many(:courses).through(:user_course_associations) }
  it { should have_many(:user_course_associations).dependent(:destroy) }
  it { should have_many(:courses_owned) }

  # Environment
  it { should have_many(:environments).through(:user_environment_associations) }
  it { should have_many(:user_environment_associations).dependent(:destroy) }
  it { should have_many(:environments_owned) }

  # Forum
  it { should have_many(:forums).through(:moderatorships) }
  it { should have_many(:monitored_topics).through(:monitorships) }
  [:moderatorships, :monitorships, :sb_posts, :topics].each do |attr|
    it { should have_many(attr).dependent(:destroy)}
  end

  # Plan
  it { should have_many(:plans) }

  it { should_not allow_mass_assignment_of :admin }
  it { should_not allow_mass_assignment_of :role_id }
  it { should_not allow_mass_assignment_of :activation_code }
  it { should_not allow_mass_assignment_of :login_slug }
  it { should_not allow_mass_assignment_of :friends_count }
  it { should_not allow_mass_assignment_of :score }
  it { should_not allow_mass_assignment_of :removed }
  it { should_not allow_mass_assignment_of :sb_posts_count }
  it { should_not allow_mass_assignment_of :sb_last_seen_at }

  [:first_name, :last_name].each do |attr|
    it { should validate_presence_of attr}
  end

  [:login, :email].each do |attr|
    it do
      pending "Need fix on shoulda's translation problem" do
        should validate_presence_of attr
      end
    end
  end

  [:login, :email, :login_slug].each do |attr|
    it do
      pending "Need fix on shoulda's translation problem" do
        should validate_uniqueness_of attr
      end
    end
  end
  it { should validate_acceptance_of :tos }

  context "validations" do
    it "validates login exclusion of reserved_logins" do
      subject.login = 'admin'
      subject.should_not be_valid
      subject.errors.on(:login).should_not be_nil
    end

    it "validates birthday to be before of 13 years ago" do
      subject.birthday = 10.years.ago
      subject.should_not be_valid
      subject.errors.on(:birthday).should_not be_nil
    end

    it "validates a curriculum type on update" do
      pending "This test is a false positive" do
        c = File.new('invalid_curriculum.pdf', 'w+')
        subject.curriculum = c
        subject.save
        File.delete('invalid_curriculum.pdf')
        subject.errors.on(:curriculum).should_not be_nil
      end
    end
  end

  context "associations" do
    it "retrieves exams that are not clones" do
      pending "Need exam factory" do
        exam = Factory(:exame, :is_clone => false, :owner => subject)
        exam2 = Factory(:exame, :is_clone => true, :owner => subject)

        subject.exams.should == exam
      end
    end

    it "retrieves lectures that are not clones" do
      lecture = Factory(:lecture, :is_clone => false, :owner => subject)
      lecture2 = Factory(:lecture, :is_clone => true, :owner => subject)
      lecture.published = 1
      lecture2.published = 1
      lecture.save
      lecture2.save
      subject.lectures.should == [lecture]
    end

    it "retrieves subjects that are finalized" do
      space = Factory(:space)
      space.course.join subject
      subjects_finalized = (1..3).collect { Factory(:subject, :owner => subject,
                                                    :space => space,
                                                    :finalized => true) }
      subjects = (1..3).collect { Factory(:subject, :owner => subject,
                                          :space => space) }

      subject.subjects.should == subjects_finalized
    end
  end

  context "finders" do
    it "retrieves recent users" do
      users = (1..3).collect { |n| Factory(:user, :created_at => n.hour.ago) }
      User.recent.should == users
    end

    it "retrieves active users" do
      active_users = (1..3).collect { |n| Factory(:user,
                                                  :activated_at => 1.day.ago) }
      users = (1..3).collect { |n| Factory(:user) }
      User.active.should == active_users
    end

    it "retrieves users tagged with specified tag" do
      users = (1..2).collect { Factory(:user) }
      tag = Factory(:tag)
      subject.tags << tag
      users[0].tags << tag
      users[1].tags << Factory(:tag, :name => "Another tag")
      User.tagged_with(subject.tags.last.name).should == [subject, users[0]]
    end

    it "retrieves users with specified ids" do
      users = (1..4).collect { Factory(:user) }
      User.with_ids([users[0].id, users[1].id]).should == [users[0], users[1]]
    end

    it "retrives recent users order by last_request_at" do
      users = (1..12).collect { |n| Factory(:user, :created_at => n.hour.ago, 
                                            :last_request_at => (13-n).minute.ago) }
      User.n_recent(3).should == [users[11], users[10], users[9]]
    end

    it "retrieves a user by his login slug" do
      user = Factory(:user)
      User.find(subject.login_slug).should == subject
    end

    it "retrieves a user by his login or email" do
      user = Factory(:user)
      User.find_by_login_or_email(subject.login).should == subject
      User.find_by_login_or_email(subject.email).should == subject
    end
  end

  context "callbacks" do
    it "it will sanitize all attributes before save" do
      subject.login = "      User Sanitized       "
      subject.description = "some<<b>script>alert('hello')<</b>/script>"
      subject.save
      subject.login.should == "User Sanitized"
      subject.description.should =="some&lt;<b>script>alert('hello')&lt;</b>/script>"
    end

    it "make an activation code before create" do
      subject.activation_code.should_not be_nil
    end

    it "delivers a signup notification to the user after create" do
      UserNotifier.delivery_method = :test
      UserNotifier.perform_deliveries = true
      UserNotifier.deliveries = []

      subject = Factory(:user)
      UserNotifier.deliveries.size.should == 1
      UserNotifier.deliveries.last.subject.should =~ /ative a sua nova conta/
    end

    it "updates last login after create" do
      subject.last_login_at.should_not be_nil
    end
  end

  it "authenticates a user by their login and password" do
    User.authenticate(subject.login, subject.password).should == subject
  end

  it "does not authenticate a user by wrong login or password" do
    User.authenticate("another-login", subject.password).should_not == subject
    User.authenticate(subject.login, "another-pass").should_not == subject
  end

  it "encrypts a password" do
    User.encrypt("some-password", "some-salt").
      should == "6f1a2796c36f64731bd5f992dc71618c2fc38e9e"
  end

  it "verifies if a profile is complete" do
    subject = Factory(:user, :gender => 'M', :description => "Desc",
                      :tags => [Factory(:tag)])
    subject.should be_profile_complete
  end

  it "verifies if he is enrolled in a subject" do
    pending "Need subject model and factory"
  end

  it "retrieves his representation in a param" do
    subject.to_param.should == subject.login_slug
  end

  it "retrieves his posts made in current month"
  it "retrieves his posts made between last and current month"
  it "deactivates his account" do
    subject = Factory(:user, :created_at => 40.days.ago,
                      :activated_at => 1.day.ago)
    subject.deactivate
    subject.should_not be_active
  end

  it "activates his account" do
    subject = Factory(:user, :created_at => 40.days.ago,
                      :activated_at => 1.day.ago)
    subject.activate
    subject.should be_active
  end

  it "verifies if he can activate his account" do
    subject = Factory(:user)
    subject.can_activate?.should == true

    subject = Factory(:user, :activated_at => 1.day.ago)
    subject.can_activate?.should == false

    subject = Factory(:user, :created_at => 31.days.ago,
                      :activated_at => nil)
    subject.can_activate?.should == false
  end

  it "encrypts his password" do
    subject.password_salt = "some-salt"
    subject.encrypt("some-password").
      should == "6f1a2796c36f64731bd5f992dc71618c2fc38e9e"
  end

  it "verifies if he is authenticated" do
    subject.should be_authenticated(subject.password)
    subject.should_not be_authenticated("another-password")
  end

  it "resets his password" do
    old_password = subject.password
    subject.reset_password
    subject.password.should_not be == old_password
    subject.should_not be_authenticated(old_password)
    subject.should be_authenticated(subject.password)
  end

  it "retrieves his owner" do
    subject.owner.should == subject
  end

  it "updates last login" do
    last_login = subject.last_login_at
    subject.update_last_login
    subject.last_login_at.should_not == last_login
  end

  it "retrieves recommended posts for him"
  it "displays his name" do
    subject.first_name = "First"
    subject.last_name = "Last"
    subject.display_name.should == "First Last"

    subject.first_name = nil
    subject.last_name = nil
    subject.display_name.should == subject.login

    subject.removed = 1
    subject.display_name.should == "(usuário removido)"
  end

  it "retrieves his first name or login" do
    subject.f_name.should == subject.first_name
    subject.first_name = nil
    subject.f_name.should == subject.login
  end

  it "verifies if he can post on a space"
  it "retrieves his association with a thing" do
    environment = Factory(:environment)
    environment.users << subject
    subject.get_association_with(environment).
      should == subject.user_environment_associations.last

    course = Factory(:course)
    course.users << subject
    subject.get_association_with(course).
      should == subject.user_course_associations.last

    space = Factory(:space)
    space.users << subject
    subject.get_association_with(space).
      should == subject.user_space_associations.last

    pending "Need subject factory" do
      subject_entity = Factory(:subject)
      subject_entity.students << subject
      subject.get_association_with(subject_entity).
        should == subject.enrollments.last
    end
  end

  it "verifies if he is redu admin" do
    subject.should_not be_admin
    subject.role = Role[:admin]
    subject.should be_admin
  end

  it "verifies if he is environment admin of a thing" do
    environment = Factory(:environment, :owner => subject)
    environment2 = Factory(:environment)
    subject.should be_environment_admin(environment)
    subject.should_not be_environment_admin(environment2)
  end

  it "verifies if he is teacher of a thing" do
    space = Factory(:space)
    space.users << subject
    assoc = subject.user_space_associations.last
    assoc.role =  Role[:teacher]
    assoc.save
    subject.should be_teacher(space)
  end
  it "verifies if he is tutor of a thing" do
    space = Factory(:space)
    space.users << subject
    assoc = subject.user_space_associations.last
    assoc.role =  Role[:tutor]
    assoc.save
    subject.should be_tutor(space)
  end
  it "verifies if he is member of a thing" do
    environment = Factory(:environment)
    environment.users << subject
    assoc = subject.user_environment_associations.last
    assoc.role =  Role[:tutor]
    assoc.save
    subject.should be_tutor(environment)
  end

  it "verifies if is a man" do
    subject.gender = 'M'
    subject.should be_male

    subject.gender = 'F'
    subject.should_not be_male
  end

  it "verifies if is a woman" do
    subject.gender = 'F'
    subject.should be_female

    subject.gender = 'M'
    subject.should_not be_female
  end

  it "adds a thing as his favorite" do
    space = Factory(:space)
    subject.add_favorite(space.class.to_s, space.id)
    subject.favorites.last.favoritable.should == space
  end

  it "removes a thing as his favorite" do
    space = Factory(:space)
    subject.add_favorite(space.class.to_s, space.id)
    subject.rm_favorite(space.class.to_s, space.id)
    subject.favorites.should be_empty
  end

  it "verifies if a thing is one of his favorite things" do
    space = Factory(:space)
    subject.add_favorite(space.class.to_s, space.id)
    subject.has_favorite(space)
  end

  it "retrieves his profile for a subject" do
    pending "Need student profile factory" do
      student_profile = Factory(:student_profile)
      subject.student_profiles = student_profile
      subject.profile_for(student_profile.subject).should == student_profile
    end
  end
end

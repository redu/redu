require 'spec_helper'

describe User do
  subject { Factory(:user) }

  it { should have_many(:statuses) }
  [:lectures, :favorites, :statuses, :subjects].each do |attr|
    it { should have_many attr }
    end

  it { should have_many(:enrollments).dependent :destroy}

  it { should have_one(:settings).dependent(:destroy) }

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

  # ChatMessages
  it { should have_many(:chat_messages) }

  # Plan
  it { should have_many(:plans) }

  it { should have_many(:partners).through(:partner_user_associations) }
  # Curriculum
  it { should have_many(:experiences).dependent(:destroy) }
  it { should have_many(:educations).dependent(:destroy) }

  # Social networks
  it { should have_many(:social_networks).dependent(:destroy) }

  it { should_not allow_mass_assignment_of :admin }
  it { should_not allow_mass_assignment_of :role }
  it { should_not allow_mass_assignment_of :activation_code }
  it { should_not allow_mass_assignment_of :friends_count }
  it { should_not allow_mass_assignment_of :score }
  it { should_not allow_mass_assignment_of :removed }

  # UserCourseAsssociation with invited state (Course invitations)
  it { should have_many :course_invitations }

  it { should accept_nested_attributes_for :settings }
  it { should accept_nested_attributes_for :social_networks }

  it { should have_many(:logs) }
  it { should have_many(:overview).through(:status_user_associations) }
  it { should have_many(:statuses) }
  it { should have_many(:status_user_associations).dependent(:destroy) }
  it { should have_many(:results).dependent(:destroy) }

  it { User.new.should respond_to(:notify).with(1) }

  [:first_name, :last_name].each do |attr|
    it do
      pending "Need fix on shoulda's translation problem" do
        should validate_presence_of attr
      end
    end
  end

  [:login, :email].each do |attr|
    it do
      pending "Need fix on shoulda's translation problem" do
        should validate_presence_of attr
      end
    end
  end

  [:login, :email].each do |attr|
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
      subject.errors[:login].should_not be_empty
    end

    it "validates birthday to be before of 13 years ago" do
      subject.birthday = 10.years.ago
      subject.should_not be_valid
      subject.errors[:birthday].should_not be_empty
    end

    it "should validate email and email_confirmation equality" do
      u = Factory.build(:user, :email => "email@email.com",
                        :email_confirmation => "different@email.com")
      u.should_not be_valid
      u.errors[:email].should_not be_empty
    end

    it "validates e-mail format" do
      u = Factory.build(:user, :email => "invalid@inv")
      u.should_not be_valid
      u.errors[:email].should_not be_empty
    end

    it "validates mobile phone format" do
      u = Factory.build(:user, :mobile => "21312312")
      u.should_not be_valid
      u.errors[:mobile].should_not be_empty
      u.mobile = "+55 (81) 1231-2131"
      u.should be_valid
      u.mobile = "81 2131-2123"
      u.should_not be_valid
    end

    context "humanizer" do
      it "should not be valid when enabling humanizer (User#enable_humanizer)" do
        User.any_instance.stub(:enable_humanizer).and_return(true)
        Factory.build(:user).should_not be_valid
      end
    end
  end

  context "associations" do
    it "retrieves lectures that are not clones" do
      environment = Factory(:environment, :owner => subject)
      course = Factory(:course, :owner => environment.owner,
                       :environment => environment)
      @space = Factory(:space, :owner => environment.owner,
                       :course => course)
      @sub = Factory(:subject, :owner => subject, :space => @space)
      lecture = Factory(:lecture, :subject => @sub,
                        :is_clone => false, :owner => subject)
      lecture2 = Factory(:lecture, :subject => @sub,
                         :is_clone => true, :owner => subject)
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

      subject.tag_list = "tag"
      subject.save

      users[0].tag_list = "tag"
      users[0].save
      users[1].tag_list = "tag2"
      users[1].save

      User.tagged_with("tag").to_set.should == [subject, users[0]].to_set
    end

    it "retrieves users with specified ids" do
      users = (1..4).collect { Factory(:user) }
      User.with_ids([users[0].id, users[1].id]).should == [users[0], users[1]]
    end

    it "retrieves a user by his login slug" do
      user = Factory(:user)
      User.find(subject.login).should == subject
    end

    it "retrieves a user by his login or email" do
      user = Factory(:user)
      User.find_by_login_or_email(subject.login).should == subject
      User.find_by_login_or_email(subject.email).should == subject
    end

    it "retrieves course invitations" do
      courses = (0..3).collect { Factory(:course) }
      courses[0].subscription_type = 2
      courses[0].join subject
      courses[1].subscription_type = 2
      courses[1].join subject
      assoc = courses[2].invite subject
      assoc2 = courses[3].invite subject

      subject.course_invitations.should == [assoc, assoc2]
    end

    it "retrieves a user by name, login or email" do
      users = []
      users << Factory(:user, :first_name => "Guilherme")
      users << Factory(:user, :login => "guilherme")
      users << Factory(:user, :email => "guiocavalcanti@redu.com.br")

      User.with_keyword("guilherme").to_set.should == [users[0], users[1]].to_set
    end

    context 'when a user has multiple spaces in the end of his name' do
      before do
        # Usuários old style
        @tarci = Factory.build(:user, :first_name => "TARCISIO   ",
                              :last_name => "COUTINHO")
        @tarci.save(:validate => false)
      end

      it 'retrieves a user by name' do
        User.with_keyword("tarcisio coutinho").to_set.should == [@tarci].to_set
      end
    end

    it "should retrieve a presence channel name" do
      subject.presence_channel.should == "presence-user-#{subject.id}"
    end

    it "should retrive a private channel name with a contact" do
      @contact = Factory(:user)
      subject.private_channel_with(@contact).should ==
        "private-#{@contact.id}-#{subject.id}"
    end

    it "retrieves the 5 most popular users (more friends)" do
      @popular = (1..3).collect { |i| Factory(:user, :friends_count => 20 + i) }
      @less_popular = (1..3).collect {|i| Factory(:user, :friends_count => 10 - i) }
      @not_popular = (1..5).collect {|i| Factory(:user, :friends_count => 3) }

      User.popular(5).to_set.should == (@popular + @less_popular[0..1]).to_set
    end

    it "retrieves the 3 most popular teachers" do
      @popular = (1..3).collect { |i| Factory(:user, :friends_count => 20 + i) }
      @less_popular = (1..3).collect {|i| Factory(:user, :friends_count => 10 - i) }
      @not_popular = (1..5).collect {|i| Factory(:user, :friends_count => 3) }

      @course = Factory(:course)
      @course2 = Factory(:course)

      @course.join @popular[1], Role[:teacher]
      @course2.join @less_popular[1], Role[:teacher]
      @course2.join @not_popular[1], Role[:teacher]

      @course.join @popular[0]
      @course.join @popular[2]
      @course2.join @less_popular[0]

      User.popular_teachers(3).should == [@popular[1], @less_popular[1],
        @not_popular[1]]
    end

    it "retrieves users with email domain like 'redu.com.br'" do
      @hotmail_users = (1..3).collect do |n|
        Factory(:user, :email => "#{n}@hotmail.com")
      end

      @gmail_users =  (1..3).collect do |n|
        Factory(:user, :email => "#{n}@gmail.com")
      end

      @redu_users =  (1..3).collect do |n|
        Factory(:user, :email => "#{n}@redu.com")
      end

      User.with_email_domain_like("administrator@redu.com").should == @redu_users
    end

    it "retrieves all users except the specified users" do
      users = (1..10).collect { Factory(:user) }
      User.without_ids(users[0..1]).should == users[2..10]
    end

    it "retrieves all colleagues (same course but not friends or pending friends)" do
      user = Factory(:user)
      owner = Factory(:user)
      env = Factory(:environment, :owner => owner)
      colleagues1 = (1..10).collect { Factory(:user) }
      friends1 = (1..5).collect { Factory(:user) }
      course1 = Factory(:course, :environment => env, :owner => owner)

      colleagues2 = (1..10).collect { Factory(:user) }
      friends2 = (1..5).collect { Factory(:user) }
      course2 = Factory(:course, :environment => env, :owner => owner)

      pending_friends = (1..10).collect { Factory(:user) }

      course1.join user
      course2.join user
      colleagues1.each do |u|
        course1.join u
      end
      friends1.each do |u|
        course1.join u
        user.be_friends_with(u)
        u.be_friends_with(user)
      end

      colleagues2.each do |u|
        course2.join u
      end
      friends2.each do |u|
        course2.join u
        user.be_friends_with(u)
        u.be_friends_with(user)
      end
      pending_friends.each do |u|
        course2.join u
        u.be_friends_with(user)
      end

      user.reload.colleagues(30).to_set.should ==
        (colleagues1 + colleagues2 << owner).to_set
    end

    it "retrieves all friends of friends (exclude pending friends)" do
      vader = Factory(:user, :login => "darth_vader")
      luke = Factory(:user, :login => "luke_skywalker")
      leia = Factory(:user, :login => "princess_leia")
      han_solo = Factory(:user, :login => "han_solo")
      yoda = Factory(:user, :login => "yodaa")

      create_friendship vader, luke
      create_friendship vader, leia
      create_friendship luke, leia
      create_friendship luke, yoda
      create_friendship leia, han_solo
      vader.be_friends_with han_solo

      vader.friends_of_friends.should == [yoda]
    end

    it "should retrieves all recipients passing a set of reccipients ids " do
      vader = Factory(:user, :login => "vader")
      luke = Factory(:user, :login => "luke_skywalker")
      leia = Factory(:user, :login => "princess_leia")
      han_solo = Factory(:user, :login => "han_solo")

      User.message_recipients([vader.id, luke.id]).should == [vader, luke]
    end

    it "retrieves all subjects ids from your lectures" do
      @lecture = Factory(:lecture, :owner => subject)
      subject.lectures << @lecture

      @id = @lecture.subject.id
      subject.subjects_id.should eq([@id])
    end
  end

  context "callbacks" do
    it "make an activation code before create" do
      subject.activation_code.should_not be_nil
    end

    it "delivers a signup notification to the user after create" do
      UserNotifier.delivery_method = :test
      UserNotifier.perform_deliveries = true
      UserNotifier.deliveries = []

      ActiveRecord::Observer.with_observers(:user_observer) do
        subject = Factory(:user)
      end

      UserNotifier.deliveries.size.should == 1
      UserNotifier.deliveries.last.subject.should =~ /Ative sua conta/
    end

    it "updates last login after create" do
      subject.last_login_at.should_not be_nil
    end

    context "when creating an user with empty whitespaces" do
      before do
        @my_user = Factory.build(:user,
          :login => "  vader   ", :email => " coisa@gmail.com",
          :first_name => " darth     ", :last_name => " vader da silva   ")
      end

      [:login, :email, :first_name, :last_name].each do |var|
        it "should trim #{var.to_s}" do
          @my_user.valid?
          /^\S+.*?\S+$/.should match @my_user.send(var)
        end
      end
    end
  end

  context "when recommending friends" do
    context "when does not have friends" do
      it "retrieves five contacts" do
        new_user = Factory(:user, :email => "user@example.com")
        teachers = (1..10).collect { Factory(:user) }
        populars = (1..20).collect { |n| Factory(:user, :friends_count => 23 + n) }
        same_domain = Factory(:user, :email => "user2@example.com")

        course = Factory(:course)
        teachers.each {|t| course.join(t, Role[:teacher])}

        new_user.recommended_contacts(5).length.should == 5
      end

      it "the user is not included" do
        new_user = Factory(:user, :email => "user@example.com")
        populars = (1..2).collect { |n| Factory(:user, :friends_count => 23 + n) }
        new_user.recommended_contacts(5).should_not include(new_user)
      end
    end
  end

  context "when exists compound statuses" do
    before do
      @page = 1
      # Criando friendship (para gerar um status compondable)
      ActiveRecord::Observer.with_observers(
        :log_observer,
        :friendship_observer,
        :status_observer) do
          @friends = 3.times.collect { Factory(:user) }
          @friends[0].be_friends_with(subject)
          subject.be_friends_with(@friends[0])
          @friends[1].be_friends_with(subject)
          subject.be_friends_with(@friends[1])
          @friends[2].be_friends_with(subject)
          subject.be_friends_with(@friends[2])

          @friends[1].be_friends_with(@friends[0])
          @friends[0].be_friends_with(@friends[1])
       end

      @last_compound = CompoundLog.where(:statusable_id => subject.id).last

      @statuses = @friends[0].overview.where(:compound => false).
        paginate(:page => @page,
                 :order => 'updated_at DESC',
                 :per_page => Redu::Application.config.items_per_page)
    end

    it "assigns correctly number of statuses" do
      @friends[0].home_activity(@page).should == @statuses
    end

    it "should create an status user association between compound log and user" do
      StatusUserAssociation.where(:user_id => subject.id,
                                  :status_id => @last_compound.id).should_not be_empty
    end

    it "should notify all friends about compound log through status user association" do

      subject.friends.each do |friend|
        StatusUserAssociation.where(:user_id => friend.id,
                                    :status_id => @last_compound.id).should_not be_empty
      end
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
    subject = Factory(:user, :gender => 'M', :description => "Desc")
    subject.tag_list = "one, two, three"
    subject.save

    subject.should be_profile_complete
  end

  it "verifies if he is enrolled in a subject" do
    pending "Need subject model and factory"
  end

  it "retrieves his representation in a param" do
    subject.to_param.should == subject.login
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

  it "verifies if he can post on a space"
  it "retrieves his association with a thing" do
    environment = Factory(:environment)
    course = Factory(:course, :environment => environment,
                     :owner => environment.owner)
    space = Factory(:space, :owner => environment.owner,
                    :course => course)
    course.join(subject)

    subject.get_association_with(environment).
      should == subject.user_environment_associations.last
    subject.get_association_with(course).
      should == subject.user_course_associations.last
    subject.get_association_with(space).
      should == subject.user_space_associations.last

    subject_entity = Factory(:subject, :owner => subject,
                             :space => space, :finalized => true)
    subject_entity.create_enrollment_associations
    subject.get_association_with(subject_entity).
      should == subject.enrollments.last

    lecture_entity = Factory(:lecture, :subject => subject_entity,
                             :owner => subject)
    subject.get_association_with(lecture_entity).
      should == subject.enrollments.last
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

  it "retrieves completeness percentage of profile" do
    subject.completeness.should == 31
  end

  it "creates user settings!" do
    subject.create_settings!
    subject.reload.settings.should_not be_nil
    subject.settings.view_mural.should == Privacy[:friends]
  end

  it "should retrieve educations most important \
    in order > higher_education > complementary_course > high_school" do

    edu1 = Factory(:education, :user => subject,
                   :educationable => Factory(:high_school))
    edu2 = Factory(:education, :user => subject,
                   :educationable => Factory(:higher_education))
    edu3 = Factory(:education, :user => subject,
                   :educationable => Factory(:complementary_course))

    subject.reload
    subject.most_important_education.should == [edu2, edu3, edu1]
  end

  context "when application validation fail" do
    it "should prevent duplicate logins" do
      @duplicate = Factory.build(:user, :login => subject.login)
      expect {
        @duplicate.save(:validate => false)
      }.should raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'create_with_omniauth' do

    context "when facebook authenticated user with valid fields" do
      before { @auth = OmniAuth.config.mock_auth[:facebook] }

      context "and user nickname has points" do
        before do
          @temp = @auth[:info][:nickname]
          @auth[:info][:nickname] = "nick.with.points"
        end

        after do
          @auth[:info][:nickname] = @temp
        end

        it "should generate a valid login" do
          User.create_with_omniauth(@auth).should be_valid
        end
      end

      context "and user nickname exceeds max length" do
        before do
          @temp = @auth[:info][:nickname]
          @auth[:info][:nickname] = "onenicknamewithshitlengthvalidonfacebook"
        end

        after do
          @auth[:info][:nickname] = @temp
        end

        it "should generate a valid login" do
          User.create_with_omniauth(@auth).should be_valid
        end

        context "and there's already an user with generated valid login" do
          before { Factory.create(:user, :login => 'onenicknamewithshitl') }

          it "should generate a valid login" do
            User.create_with_omniauth(@auth).should be_valid
          end
        end
      end

      context "but there's already an user with given nickname" do
        before { Factory.create(:user, :login => 'SomeUserville') }

        it "should return a valid user" do
          User.create_with_omniauth(@auth).should be_valid
        end

        context "and the most obvious nickname is taken too" do
          before { Factory.create(:user, :login => 'SomeUserville1') }

          it "should return a valid user" do
            User.create_with_omniauth(@auth).should be_valid
          end
        end
      end

      it 'should create a new user' do
        expect {
          User.create_with_omniauth(@auth)
        }.to change(User, :count).by(1)
      end

      it 'should set login for new user properly' do
        User.create_with_omniauth(@auth).login.should_not be_nil
      end

      it 'should set e-mail for new user properly' do
        User.create_with_omniauth(@auth).email.should == @auth[:info][:email]
      end

      it 'should set first name for new user properly' do
        User.create_with_omniauth(@auth).first_name.should == @auth[:info][:first_name]
      end

      it 'should set last name for new user properly' do
        User.create_with_omniauth(@auth).last_name.should == @auth[:info][:last_name]
      end

      it 'should create a new authentication' do
        expect {
          User.create_with_omniauth(@auth)
        }.to change(Authentication, :count).by(1)
      end

      it 'should create a new authentication for correct user' do
        login = User.get_login_from_provider_username(@auth[:info])
        User.create_with_omniauth(@auth)
        Authentication.find_by_uid(@auth[:uid]).user.should == User.
          find(login)
      end

      it 'should set uid for new authentication properly' do
        User.create_with_omniauth(@auth)
        Authentication.find_by_uid(@auth[:uid]).should_not be_nil
      end

      it 'should set provider for new authentication properly' do
        User.create_with_omniauth(@auth)
        Authentication.find_by_uid(@auth[:uid]).provider.should == @auth[:provider]
      end
    end # context "when facebook authenticated user with valid fields"
  end # describe 'create_with_omniauth'

  private
  def create_friendship(user1, user2)
    user1.be_friends_with(user2)
    user2.be_friends_with(user1)
  end
end

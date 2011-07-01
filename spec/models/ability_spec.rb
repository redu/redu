require 'spec_helper'
require 'cancan/matchers'

describe Ability do

  before do
    @env_admin = Factory(:user)
    @member = Factory(:user)
    @teacher = Factory(:user)
    @tutor = Factory(:user)
    @redu_admin = Factory(:user, :role => :admin)
  end

  context "on environment -" do

    before do
      @environment = Factory(:environment, :owner => @env_admin)
    end

    context "member" do
      before do
        Factory(:user_environment_association, :environment => @environment,
                :user => @member, :role => :member)
        @ability = Ability.new(@member)
      end
      it "creates a environment" do
        env = Factory.build(:environment, :owner => @member)
        @ability.should be_able_to(:create, env)
      end

      it "destroys his own environment" do
        @ability.should be_able_to(:destroy, Factory(:environment, :owner => @member))
      end
      it "cannot destroy a strange environment" do
        @ability.should_not be_able_to(:destroy, @environment)
      end
    end

    context "envinronment_admin" do
      before do
        @ability = Ability.new(@env_admin)
      end
      #FIXME aparentemente um usuário pode criar um ambiente em que o owner seja outro usuário
      it "creates a environment" do
        @ability.should be_able_to(:create, Factory.build(:environment,
                                                          :owner => @env_admin))
      end
      it "destroy his own environment" do
        @ability.should be_able_to(:destroy, @environment)
      end

      it "cannot destroy a strange environment" do
        @ability.should_not be_able_to(:destroy,
                                       Factory.build(:environment,
                                                     :owner => @redu_admin))
      end
    end

    context "teacher" do
      before do
        Factory(:user_environment_association, :environment => @environment,
                :user => @teacher, :role => :teacher)
        @ability = Ability.new(@teacher)
      end

      it "creates a environment" do
        @ability.should be_able_to(:create,
                                   Factory.build(:environment,
                                                 :owner => @teacher))
      end
      it "destroy his own environment" do
        @ability.should be_able_to(:destroy,
                                   Factory(:environment,
                                           :owner => @teacher))
      end
      it "cannot destroy a strange environment" do
        @ability.should_not be_able_to(:destroy, @environment)
      end
    end

    context "tutor" do
      before do
        Factory(:user_environment_association, :environment => @environment,
                :user => @tutor, :role => :teacher)
        @ability = Ability.new(@tutor)
      end
      it "creates a environment" do
        @ability.should be_able_to(:create, Factory.build(:environment,
                                                          :owner => @tutor))
      end

      it "destroy his own environment" do
        @ability.should be_able_to(:destroy, Factory(:environment,
                                                     :owner => @tutor))
      end

      it "cannot destroy a strange environment" do
        @ability.should_not be_able_to(:destroy, @environment)
      end

    end

    context "redu admin" do
      before do
        @ability = Ability.new(@redu_admin)
      end
      it "creates a environment" do
        @ability.should be_able_to(:create,
                                   Factory.build(:environment,
                                                 :owner => @redu_admin))
      end

      it "destroy his own environment" do
        @ability.should be_able_to(:destroy, Factory(:environment,
                                                     :owner => @redu_admin))
      end
      it "cannot destroy a strange environment" do
        @ability.should be_able_to(:destroy, @environment)
      end
    end

  end

  context "on course -" do
    before do
      @environment = Factory(:environment, :owner => @env_admin)
      Factory(:user_environment_association, :environment => @environment,
              :user => @member, :role => :member)
    end

    context "member" do
      before do
        @ability = Ability.new(@member)
      end

      it "cannot create a course" do
        course = Factory.build(:course,:owner => @member,
                               :environment => @environment)
        @ability.should_not be_able_to(:create, course)
      end

      it "cannot destroy a course" do
        course = Factory.build(:course, :owner => @env_admin,
                               :environment => @environment)
        @ability.should_not be_able_to(:destroy, course)
      end

      it "accepts a course invitation" do
        course = Factory(:course, :owner => @env_admin,
                         :environment => @environment)
        course.invite(@member)
        @ability.should be_able_to(:accept, course)
      end

      it "denies a course invitation" do
        course = Factory(:course, :owner => @env_admin,
                         :environment => @environment)
        course.invite(@member)
        @ability.should be_able_to(:deny, course)
      end

      it "cannot create a bulletin"
      it "cannot destroy a bulletin"

      it "cannot invite users" do
        course = Factory(:course)
        @ability.should_not be_able_to(:invite_members, course)
      end
    end

    context "environment admin" do
      before  do
        @ability = Ability.new(@env_admin)
      end
      it "creates a course"  do
        course = Factory.build(:course, :owner => @env_admin,
                               :environment => @environment)
        @ability.should be_able_to(:create, course)
      end
      it "destroys his course" do
        course = Factory.build(:course, :owner => @env_admin,
                               :environment => @environment)
        @ability.should be_able_to(:destroy, course)
      end
      it "destroys a strange course when he is a environment admin" do
        cur_user = Factory(:user)
        Factory(:user_environment_association, :environment => @environment,
                :user => cur_user, :role => :environment_admin)
        course = Factory.build(:course, :owner => cur_user,
                               :environment => @environment)
        @ability.should be_able_to(:destroy, course)
      end

      it "cannot destroy a course when he isn't a environment admin" do
        cur_user = Factory(:user)
        environment_out = Factory(:environment, :owner => cur_user)
        course = Factory.build(:course, :owner => cur_user,
                               :environment => environment_out)
        @ability.should_not be_able_to(:destroy, course)
      end

      context "if plan is blocked" do
        before do
          @course = Factory(:course,:owner => @env_admin,
                            :environment => @environment)
          @plan = Factory(:plan, :billable => @course)
          @plan.block!
          @space = Factory(:space, :owner => @env_admin, :course => @course)
          @sub = Factory(:subject, :owner => @env_admin, :space => @space)
        end

        # Sorry, but Document #1 could not be uploaded to Scribd
        pending do
          it "can NOT upload document" do
            document = Factory(:document)
            lecture = Factory(:lecture, :owner => @env_admin,
                              :subject => @sub,
                              :lectureable => document)
            @ability.should_not be_able_to(:upload_document, document)
          end
        end

        # Need Seminar factory
        it "can NOT upload multimedia"

        it "can create a Youtube seminar" do
          youtube = Factory.build(:seminar_youtube)
          lecture = Factory(:lecture, :owner => @env_admin,
                            :subject => @sub,
                            :lectureable => youtube)
          @ability.should be_able_to(:upload_multimedia, youtube)
        end

        # Need Myfile factory
        it "can NOT upload file"
      end

      it "creates a bulletin"
      it "destroy a bulletin when he is a environment admin"

      it "invites members" do
        course = Factory(:course, :owner => @env_admin,
                         :environment => @environment)
        @ability.should be_able_to(:invite_members, course)
      end

      it "views not accepted invitations" do
        course = Factory(:course, :owner => @env_admin,
                         :environment => @environment)
        @ability.should be_able_to(:admin_manage_invitations, course)
      end

      it "destroys invitations" do
        course = Factory(:course, :owner => @env_admin,
                         :environment => @environment)
        @ability.should be_able_to(:destroy_invitations, course)
      end
    end

    context "teacher" do
      before do
        @ability = Ability.new(@teacher)
        Factory(:user_environment_association, :environment => @environment,
                :user => @teacher, :role => :teacher)
      end
      it "cannot create a course" do
        course = Factory.build(:course,:owner => @teacher,
                               :environment => @environment)
        @ability.should_not be_able_to(:create, course)
      end
      it "cannot destroy a course" do
        course = Factory.build(:course,:owner => @teacher,
                               :environment => @environment)
        @ability.should_not be_able_to(:destroy, course)
      end
      it "cannot create a bulletin"
      it "cannot destroy a bulletin"

      it "cannot invite members" do
        course = Factory.build(:course,:owner => @teacher,
                               :environment => @environment)
        @ability.should_not be_able_to(:invite_members, course)
      end

      it "cannot view not accepted invitations" do
        course = Factory(:course, :owner => @env_admin,
                         :environment => @environment)
        @ability.should_not be_able_to(:admin_manage_invitations, course)
      end

      it "cannot destroy invitations" do
        course = Factory(:course, :owner => @env_admin,
                         :environment => @environment)
        @ability.should_not be_able_to(:destroy_invitations, course)
      end
    end

    context "tutor" do
      before do
        @ability = Ability.new(@tutor)
        Factory(:user_environment_association, :environment => @environment,
                :user => @tutor, :role => :teacher)
      end
      it "cannot create a course" do
        course = Factory.build(:course,:owner => @tutor,
                               :environment => @environment)
        @ability.should_not be_able_to(:create, course)
      end
      it "cannot destroy a course" do
        course = Factory.build(:course,:owner => @tutor,
                               :environment => @environment)
        @ability.should_not be_able_to(:destroy, course)
      end

      it "cannot create a bulletin"
      it "cannot destroy a bulletin"

      it "cannot invite members" do
        course = Factory.build(:course,:owner => @tutor,
                               :environment => @environment)
        @ability.should_not be_able_to(:invite_members, course)
      end
    end

    context "redu admin" do
      before  do
        @ability = Ability.new(@redu_admin)
      end
      it "creates a course"  do
        course = Factory.build(:course, :owner => @redu_admin,
                               :environment => @environment)
        @ability.should be_able_to(:create, course)
      end
      it "destroys his course" do
        course = Factory.build(:course, :owner => @redu_admin,
                               :environment => @environment)
        @ability.should be_able_to(:destroy, course)
      end
      it "destroys any course" do
        course = Factory.build(:course,
                               :environment => @environment)
        @ability.should be_able_to(:destroy, course)
      end
      it "creates a bulletin"
      it "destroy any bulletin"
    end

  end

  context "on space -" do
    before do
      @environment = Factory(:environment, :owner => @env_admin)
      @course = Factory(:course, :owner => @env_admin,
                        :environment => @environment)
    end
    context "member" do
      before do
        Factory(:user_environment_association, :environment => @environment,
                :user => @member, :role => :member)
        Factory(:user_course_association, :course => @course,
                :user => @member, :role => :member)
        @ability = Ability.new(@member)
      end

      it "cannot create a space" do
        @ability.should_not be_able_to(:create, Factory(:space,
                                                        :owner => @member,
                                                        :course => @course))
      end
      it "cannot destroy a space" do
        @ability.should_not be_able_to(:destroy, Factory(:space,
                                                         :owner => @member,
                                                         :course => @course))
      end

      it "cannot create a subject"
      it "cannot destroy any subject"
      it "cannot create a lecture"
      it "cannot destroy any lecture"
      it "cannot create an event"
      it "cannot destroy any event"
      it "cannot create a bulletin"
      it "cannot destroy any bulletin"
      it "cannot upload a file"
      it "cannot destroy any file"
      it "crates a post"

    end

    context "teacher" do
      before do
        Factory(:user_environment_association, :environment => @environment,
                :user => @teacher, :role => :teacher)
        Factory(:user_course_association, :course => @course,
                :user => @teacher, :role => :teacher)
        @space = Factory(:space, :owner => @teacher,
                         :course => @course)
        @ability = Ability.new(@teacher)
      end
      it "creates a space" do
        @ability.should be_able_to(:create, @space)
      end
      it "destroys his own space" do
        @ability.should be_able_to(:destroy, @space)
      end
      it "cannot destroy a strange space where he is a teacher" do
        environment1 = Factory(:environment)
        course1 = Factory.build(:course, :owner => environment1.owner,
                                :environment => environment1)
        space1 = Factory.build(:space, :owner => @teacher,
                               :course => course1)
        @ability.should_not be_able_to(:destroy, space1)
      end

      it "creates a subject"
      it "destroys any subject"
      it "creates a lecture"
      it "destroys any lecture"
      it "creates an event"
      it "destroys any event"
      it "creates a bulletin"
      it "destroys any bulletin"
      it "uploads a file"
      it "destroys any file"
      it "crates a post"
    end

    context "tutor" do
      before do
        Factory(:user_environment_association, :environment => @environment,
                :user => @tutor, :role => :member)
        Factory(:user_course_association, :course => @course,
                :user => @tutor, :role => :member)
        @ability = Ability.new(@tutor)
      end

      it "cannot create a space" do
        @ability.should_not be_able_to(:create, Factory(:space,
                                                        :owner => @tutor,
                                                        :course => @course))
      end
      it "cannot destroy a space" do
        @ability.should_not be_able_to(:destroy, Factory(:space,
                                                         :owner => @tutor,
                                                         :course => @course))
      end

      it "cannot create a subject"
      it "cannot destroy any subject"
      it "cannot create a lecture"
      it "cannot destroy any lecture"
      it "cannot create an event"
      it "cannot destroy any event"
      it "cannot create a bulletin"
      it "cannot destroy any bulletin"
      it "cannot upload a file"
      it "cannot destroy any file"
      it "crates a post"
    end

    context "environment admin" do
      before do
        @ability = Ability.new(@env_admin)
      end
      it "creates a space" do
        space = Factory(:space, :owner => @env_admin,
                        :course => @course)
        @ability.should be_able_to(:create, space)
      end
      it "destroys a space" do
        space = Factory(:space, :owner => @env_admin,
                        :course => @course)
        @ability.should be_able_to(:destroy, space)
      end
      it "creates a subject"
      it "destroys any subject"
      it "creates a lecture"
      it "destroys any lecture"
      it "creates an event"
      it "destroys any event"
      it "creates a bulletin"
      it "destroys any bulletin"
      it "uploads a file"
      it "destroys any file"
      it "crates a post"
    end

    context "redu admin" do
      before do
        @ability = Ability.new(@redu_admin)
      end
      it "creates a space" do
        space = Factory(:space, :owner => @redu_admin,
                        :course => @course)
        @ability.should be_able_to(:create, space)
      end
      it "destroys a space" do
        space = Factory(:space, :owner => @env_admin,
                        :course => @course)
        @ability.should be_able_to(:destroy, space)
      end
      it "creates a subject"
      it "destroys any subject"
      it "creates a lecture"
      it "destroys any lecture"
      it "creates an event"
      it "destroys any event"
      it "creates a bulletin"
      it "destroys any bulletin"
      it "uploads a file"
      it "destroys any file"
      it "crates a post"
    end
  end

  context "on plan" do
    before do
      @plan = Factory(:plan)
      @invoice = Factory(:invoice, :plan => @plan)
    end

    context "the owner" do
      before do
        @ability = Ability.new(@plan.user)
      end

      it "read its own plan" do
        @ability.should be_able_to(:read, @plan)
      end

      it "manages its own plan" do
        @ability.should be_able_to(:manage, @plan)
      end

      it "reads plan's invoice" do
        @ability.should be_able_to(:read, @invoice)
      end

      it "manages plan's invoice" do
        @ability.should be_able_to(:manage, @invoice)
      end
    end
  end

  context "the strange" do
    before do
      strange = Factory(:user)

      @plan = Factory(:plan)
      @invoice = Factory(:invoice, :plan => @plan)
      @ability = Ability.new(strange)
    end

    it "can NOT read others plans" do
      @ability.should_not be_able_to(:read, @plan)
    end

    it "can NOT manage others plans" do
      @ability.should_not be_able_to(:manage, @plan)
    end

    it "can NOT read others plan's invoice" do
      @ability.should_not be_able_to(:read, @invoice)
    end
    it "can NOT manage others plan's invoice" do
      @ability.should_not be_able_to(:manage, @invoice)
    end
  end

  context "on user -" do
    before do
      @user = Factory(:user)
      @user_ability = Ability.new(@user)
    end

    context "pusher channels" do
      before do
        @stranger = Factory(:user)
        @friend = Factory(:user)

        friendship, status = @user.be_friends_with(@friend)
        friendship.accept!
      end

      it "can auth a channel" do
        @user_ability.should be_able_to(:auth, @user)
      end

      it "can NOT auth a contact channel" do
        @user_ability.should_not be_able_to(:auth, @friend)
      end

      it "can subscribe a contact channel" do
        @user_ability.should be_able_to(:subscribe_channel, @friend)
      end

      it "can NOT subscribe a stranger channel" do
        @user_ability.should_not be_able_to(:subscribe_channel, @stranger)
      end

      context "when chatting" do
        before do
          course = Factory(:course)
          @colleague = Factory(:user)
          @teacher = Factory(:user)
          course.join(@user)
          course.join(@colleague)
          course.join(@teacher, Role[:teacher])
        end

        it "can send a message to a friend" do
          @user_ability.should be_able_to(:send_chat_message, @friend)
        end

        it "can send a message to a teacher" do
          @user_ability.should be_able_to(:send_chat_message, @teacher)
        end

        it "can NOT send a message to a colleague" do
          @user_ability.should_not be_able_to(:send_chat_message, @colleague)
        end

        it "can NOT send a message to a stranger" do
          @user_ability.should_not be_able_to(:send_chat_message, @stranger)
        end
      end

      context "when requesting last chat messages" do
        before do
          course = Factory(:course)
          @colleague = Factory(:user)
          @teacher = Factory(:user)
          course.join(@user)
          course.join(@colleague)
          course.join(@teacher, Role[:teacher])
        end

        it "can request his messages with a teacher" do
          @user_ability.should be_able_to(:last_messages_with, @teacher)
        end

        it "can NOT request his messages with a colleague" do
          @user_ability.should_not be_able_to(:last_messages_with, @colleague)
        end

       it "can NOT request his messages with a stranger" do
          @user_ability.should_not be_able_to(:last_messages_with, @stranger)
        end
      end


    end

    context "when friends" do
      before do
        @my_friend = Factory(:user)
        @my_friend_ability = Ability.new(@my_friend)

        friendship, status = @user.be_friends_with(@my_friend)
        friendship.accept!
      end

      it "should read each other" do
        @user_ability.should be_able_to(:read, @my_friend)
        @my_friend_ability.should be_able_to(:read, @user)
      end

      it "should not manage each other" do
        @user_ability.should_not be_able_to(:manage, @my_friend)
        @my_friend_ability.should_not be_able_to(:manage, @user)
      end
    end

    context "when user privacy" do
      context "let everyone see his statuses" do
        before do
          @user.settings.view_mural = Privacy[:public]
        end

        context "and they are friends," do
          before do
            @my_friend = Factory(:user)
            @my_friend_ability = Ability.new(@my_friend)

            friendship, status = @user.be_friends_with(@my_friend)
            friendship.accept!
          end

          it "a friend can view user's statuses" do
            @my_friend_ability.should be_able_to(:view_mural, @user)
          end
        end

        context "and they are NOT friends," do
          before do
            @someone = Factory(:user)
            @someone_ability = Ability.new(@someone)
          end

          it "someone can view user's statuses" do
            @someone_ability.should be_able_to(:view_mural, @user)
          end
        end
      end

      context "let ONLY friends see his statuses" do
        before do
          @user.settings.view_mural = Privacy[:friends]
        end

        context "and they are friends," do
          before do
            @my_friend = Factory(:user)
            @my_friend_ability = Ability.new(@my_friend)

            friendship, status = @user.be_friends_with(@my_friend)
            friendship.accept!
          end

          it "a friend can view user's statuses" do
            @my_friend_ability.should be_able_to(:view_mural, @user)
          end
        end

        context "and they are NOT friends," do
          before do
            @someone = Factory(:user)
            @someone_ability = Ability.new(@someone)
          end

          it "someone can NOT view user's statuses" do
            @someone_ability.should_not be_able_to(:view_mural, @user)
          end
        end
      end
    end

    it "manages itself" do
      @user_ability.should be_able_to(:manage, @user)
    end

    it "manages its own statuses" do
      status = Factory(:status, :user => @user)
      @user_ability.should be_able_to(:manage, status)
    end

    context "when destroying user" do
      before do
        @other = Factory(:user)
      end
      it "can NOT destroy others user" do
        @user_ability.should_not be_able_to(:destroy, @other)
      end

      it "can destroy its own user" do
        @user_ability.should be_able_to(:destroy, @user)
      end
    end
  end
end

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

      it "creates a bulletin"
      it "destroy a bulletin when he is a environment admin"

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

    it "manages itself" do
      @user_ability.should be_able_to(:manage, @user)
    end

    it "manages its own statuses" do
      status = Factory(:status, :user => @user)
      @user_ability.should be_able_to(:manage, status)
    end

  end
end

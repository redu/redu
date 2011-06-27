require 'spec_helper'

describe Presence do

  before do
    @current_user = Factory(:user)
    @friend1 = Factory(:user)
    @friend2 = Factory(:user)
    @friend3 = Factory(:user)
    @user2 = Factory(:user)
    @user3 = Factory(:user)
    @tutor2 = Factory(:user)
    @tutor3 = Factory(:user)
    @tutor1_and_2 = Factory(:user)
    @teacher2_and_3 = Factory(:user)
    @teacher3 = Factory(:user)

    # primeiro curso
    environment = Factory(:environment)
    @course = Factory(:course, :owner => environment.owner,
                      :environment => environment)
    space = Factory(:space, :owner => environment.owner,
                    :course => @course)

    # segundo curso
    @course2 = Factory(:course, :environment => environment,
                       :owner => environment.owner)
    @course3 = Factory(:course)

    @course.join(@friend1, Role[:teacher])
    @course2.join(@friend1, Role[:tutor])

    @course.join(@friend2)
    @course3.join(@user2)

    @course2.join(@tutor2, Role[:tutor])
    @course3.join(@tutor3, Role[:tutor])
    @course.join(@tutor1_and_2, Role[:tutor])
    @course2.join(@tutor1_and_2, Role[:tutor])

    @course2.join(@teacher2_and_3, Role[:teacher])
    @course3.join(@teacher3, Role[:teacher])

    @current_user.be_friends_with(@friend1)
    @friend1.be_friends_with(@current_user)
    @current_user.be_friends_with(@friend2)
    @friend2.be_friends_with(@current_user)
    @current_user.be_friends_with(@friend3)
    @friend3.be_friends_with(@current_user)
  end


  context "when retrieving a list of channels" do
    before do
      @course.join(@current_user)
      @course2.join(@current_user)
    end

    it "should NOT retrieve repeated elements" do
      Presence.list_of_channels(@current_user).should ==
        Presence.list_of_channels(@current_user).uniq
    end
  end

  context "when a common user enters on a Chat" do
    before do
      @course.join(@current_user)
      @course2.join(@current_user)
    end

    it "should retrieve a hash of channels of friends, teachers and tutors" do
      channels = [ {:pre_channel => "presence-user-#{@friend1.id}",
                     :pri_channel => "private-#{@current_user.id}-#{@friend1.id}"},
        {:pre_channel => "presence-user-#{@friend2.id}",
         :pri_channel => "private-#{@current_user.id}-#{@friend2.id}"},
        {:pre_channel => "presence-user-#{@friend3.id}",
         :pri_channel => "private-#{@current_user.id}-#{@friend3.id}"},
        {:pre_channel => "presence-user-#{@tutor2.id}",
         :pri_channel => "private-#{@current_user.id}-#{@tutor2.id}"},
        {:pre_channel => "presence-user-#{@tutor1_and_2.id}",
         :pri_channel => "private-#{@current_user.id}-#{@tutor1_and_2.id}"},
        {:pre_channel => "presence-user-#{@teacher2_and_3.id}",
         :pri_channel => "private-#{@current_user.id}-#{@teacher2_and_3.id}"}]
      Presence.list_of_channels(@current_user).to_set.
        should == channels.to_set
    end
  end

  context "when a teacher enters on a Chat" do
    before do
      @course.join(@current_user, Role[:teacher])
      @course2.join(@current_user)

      @course_students = (1..3).collect { Factory(:user) }
      @course_students.each { |s| @course.join(s) }

      @course2_students = (1..3).collect { Factory(:user) }
      @course2_students.each { |s| @course2.join(s) }

      @course3_students = (1..3).collect { Factory(:user) }
      @course3_students.each { |s| @course3.join(s) }
    end

    it "should retrieve a hash of channels of friends, teachers, tutors and" \
      " all users that belongs to a course that he is teacher" do
      friends = [
        { :pre_channel => "presence-user-#{@friend1.id}",
          :pri_channel => "private-#{@current_user.id}-#{@friend1.id}"},
        { :pre_channel => "presence-user-#{@friend2.id}",
          :pri_channel => "private-#{@current_user.id}-#{@friend2.id}"},
        { :pre_channel => "presence-user-#{@friend3.id}",
          :pri_channel => "private-#{@current_user.id}-#{@friend3.id}"}]

        course_users = @course.users.collect do |u|
          if @current_user.id != u.id
            { :pre_channel => "presence-user-#{u.id}",
              :pri_channel => "private-#{@current_user.id}-#{u.id}"}
          end
        end
        course_users.delete(nil)

        teachers_tutors_course2 = [
          { :pre_channel => "presence-user-#{@tutor2.id}",
            :pri_channel => "private-#{@current_user.id}-#{@tutor2.id}"},
          { :pre_channel => "presence-user-#{@tutor1_and_2.id}",
            :pri_channel => "private-#{@current_user.id}-#{@tutor1_and_2.id}"},
          { :pre_channel => "presence-user-#{@teacher2_and_3.id}",
            :pri_channel => "private-#{@current_user.id}-#{@teacher2_and_3.id}"}]
          Presence.list_of_channels(@current_user).to_set.
            should == (friends + course_users + teachers_tutors_course2).to_set
      end
  end

  context "when a tutor enters on a Chat" do
    before do
      @course.join(@current_user, Role[:tutor])
      @course2.join(@current_user)

      @course_students = (1..3).collect { Factory(:user) }
      @course_students.each { |s| @course.join(s) }

      @course2_students = (1..3).collect { Factory(:user) }
      @course2_students.each { |s| @course2.join(s) }

      @course3_students = (1..3).collect { Factory(:user) }
      @course3_students.each { |s| @course3.join(s) }
    end

    it "should retrieve a hash of channels of friends, teachers, tutors and" \
      " all users that belongs to a course that he is tutor" do
      friends = [{ :pre_channel => "presence-user-#{@friend1.id}",
        :pri_channel => "private-#{@current_user.id}-#{@friend1.id}"},
        { :pre_channel => "presence-user-#{@friend2.id}",
          :pri_channel => "private-#{@current_user.id}-#{@friend2.id}"},
        { :pre_channel => "presence-user-#{@friend3.id}",
          :pri_channel => "private-#{@current_user.id}-#{@friend3.id}"}]

        course_users = @course.users.collect do |u|
          if @current_user.id != u.id
            { :pre_channel => "presence-user-#{u.id}",
              :pri_channel => "private-#{@current_user.id}-#{u.id}" }
          end
        end
        course_users.delete(nil)

        teachers_tutors_course2 = [
          { :pre_channel => "presence-user-#{@tutor2.id}",
            :pri_channel => "private-#{@current_user.id}-#{@tutor2.id}"},
          { :pre_channel => "presence-user-#{@tutor1_and_2.id}",
            :pri_channel => "private-#{@current_user.id}-#{@tutor1_and_2.id}"},
          { :pre_channel => "presence-user-#{@teacher2_and_3.id}",
            :pri_channel => "private-#{@current_user.id}-#{@teacher2_and_3.id}"}]
          Presence.list_of_channels(@current_user).to_set.
            should == (friends + course_users + teachers_tutors_course2).to_set
      end
  end

  context "when a tutor, teacher and student enters on a Chat" do
    before do
      @course.join(@current_user, Role[:tutor])
      @course2.join(@current_user, Role[:teacher])
      @course3.join(@current_user)

      @course_students = (1..3).collect { Factory(:user) }
      @course_students.each { |s| @course.join(s) }

      @course2_students = (1..3).collect { Factory(:user) }
      @course2_students.each { |s| @course2.join(s) }

      @course3_students = (1..3).collect { Factory(:user) }
      @course3_students.each { |s| @course3.join(s) }
    end

    it "should retrieve a hash of channels of friends, teachers, tutors and" \
      " all users that belongs to a course that he is tutor" do
      friends = [
        { :pre_channel => "presence-user-#{@friend1.id}",
          :pri_channel => "private-#{@current_user.id}-#{@friend1.id}"},
        { :pre_channel => "presence-user-#{@friend2.id}",
          :pri_channel => "private-#{@current_user.id}-#{@friend2.id}"},
        { :pre_channel => "presence-user-#{@friend3.id}",
          :pri_channel => "private-#{@current_user.id}-#{@friend3.id}"}]

        course_users = @course.users.collect do |u|
          if @current_user.id != u.id
            { :pre_channel => "presence-user-#{u.id}",
              :pri_channel => "private-#{@current_user.id}-#{u.id}"}
          end
        end
        course_users.delete(nil)
        course2_users = @course2.users.collect do |u|
          if @current_user.id != u.id
            { :pre_channel => "presence-user-#{u.id}",
              :pri_channel => "private-#{@current_user.id}-#{u.id}"}
          end
        end
        course2_users.delete(nil)

        teachers_tutors_course3 = [
          { :pre_channel => "presence-user-#{@tutor3.id}",
            :pri_channel => "private-#{@current_user.id}-#{@tutor3.id}"},
          { :pre_channel => "presence-user-#{@teacher3.id}",
            :pri_channel => "private-#{@current_user.id}-#{@teacher3.id}"}]

        Presence.list_of_channels(@current_user).to_set.should ==
          (friends + course_users + course2_users + teachers_tutors_course3).to_set
      end
  end

  it "should retrieve the right roles" do
    @friend1.role = Role[:admin]
    Presence.fill_roles(@friend1).should == { "teacher" => true,
      "member" => false,
      "environment_admin" => false,
      "tutor" => true,
      "course_admin" => false,
      "admin" => true }
  end
end

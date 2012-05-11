require 'spec_helper'

describe StatusObserver do
  context "after create" do

    context "when statusable is user" do
      before do
        @owner = Factory(:user)
        @statusable = Factory(:user)

        @owner_contacts = 5.times.inject([]) do |acc, i|
          u = Factory(:user)
          u.be_friends_with(@owner)
          @owner.be_friends_with(u)
          acc << u
        end

        @statusable_contacts = 3.times.inject([]) do |acc, i|
          u = Factory(:user)
          u.be_friends_with(@statusable)
          @statusable.be_friends_with(u)
          acc << u
        end

        ActiveRecord::Observer.with_observers(:status_observer) do
          @activity = Factory(:activity,
                              :user => @owner,
                              :statusable => @statusable)
          @associations = @activity.status_user_associations
        end

      end

      it "associates the owner" do
        @owner.status_user_associations.count.should == 1
      end

      it "associates the owner contacts" do
        contacts = @owner.friends.collect do |u|
          u.status_user_associations
        end.flatten

        @owner.friends.should_not be_empty
        contacts.should_not be_empty
        contacts.to_set.should be_subset(@associations.to_set)
      end

      it "associates the statusable contacts" do
        contacts = @activity.statusable.friends.collect do |u|
          u.status_user_associations
        end.flatten

        contacts.should_not be_empty
      end
    end

    context "when statusable is Lecture" do
      before do
        @environment = Factory(:environment)
        @course = Factory(:course, :owner => @environment.owner,
                          :environment => @environment)
        @poster = Factory(:user)
        @course.join(@poster)
        @space = Factory(:space, :owner => @environment.owner,
                         :course => @course)
        @subject = Factory(:subject, :owner => @poster, :space => @space)
        @lecture = Factory(:lecture, :subject => @subject,
                           :owner => @environment.owner)

        @poster_contacts = 5.times.inject([]) do |acc, i|
          u = Factory(:user)
          u.be_friends_with(@poster)
          @poster.be_friends_with(u)
          acc << u
        end

        @students = 3.times.inject([]) do |acc, u|
          user = Factory(:user)
          @course.join(user)
          acc << user
        end

      end

      context "and status is type of Activity" do

        before do
          ActiveRecord::Observer.with_observers(:status_observer) do
            @activity = Factory(:activity, :statusable => @lecture,
                                :user => @poster)
          end
        end

        it "associates the course students" do
          @course.approved_users.to_set.should == @activity.users.to_set
        end

        it "cannot associate the poster contacts" do
          (@poster_contacts.to_set & @activity.users.to_set).should be_empty
        end
      end
    end

    context "when statusable is Space" do
      before do
        @environment = Factory(:environment)
        @course = Factory(:course, :owner => @environment.owner,
                          :environment => @environment)
        @poster = Factory(:user)
        @course.join(@poster)
        @space = Factory(:space, :owner => @environment.owner,
                         :course => @course)

        @poster_contacts = 5.times.inject([]) do |acc, i|
          u = Factory(:user)
          u.be_friends_with(@poster)
          @poster.be_friends_with(u)
          acc << u
        end

        @students = 3.times.inject([]) do |acc, u|
          user = Factory(:user)
          @course.join(user)
          acc << user
        end

        ActiveRecord::Observer.with_observers(:status_observer) do
          @activity = Factory(:activity, :statusable => @space,
                              :user => @poster)
        end
      end

      it "associates the course students" do
        @course.approved_users.to_set.should == @activity.users.to_set
      end

      it "cannot associate the poster contacts" do
        (@poster_contacts.to_set & @activity.users.to_set).should be_empty
      end

    end

    context "when statusable is UserCourseAssociation" do
      before do
        ActiveRecord::Observer.with_observers(:status_observer) do
          @uca = Factory(:user_course_association)
          @uca.approve!
          3.times { @uca.course.join(Factory(:user)) }
          @log = Log.setup(@uca)
        end
      end

      it "associates the course students" do
        @log.users.should_not be_empty
        @log.users.to_set.should == @uca.course.approved_users.to_set
      end
    end
  end
end

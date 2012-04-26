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
          WebMock.disable_net_connect!
          ActiveRecord::Observer.with_observers(:status_observer) do
            @stub = stub_request(:post, Redu::Application.config.vis_client[:url]).
              with(:headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                                'Content-Type'=>'application/json'}).
                                to_return(:status => 200, :body => "", :headers => {})

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


        it "send information of core to visualization" do
          params = {
            :lecture_id => @activity.statusable_id,
            :subject_id => @activity.statusable.subject.id,
            :space_id => @activity.statusable.subject.space.id,
            :course_id => @activity.statusable.subject.space.course.id,
            :user_id => @activity.user_id,
            :type => @activity.type.downcase,
            :status_id => @activity.id,
            :statusable_id => @activity.statusable_id,
            :statusable_type => @activity.statusable_type,
            :in_response_to_id => @activity.in_response_to_id,
            :in_response_to_type => @activity.in_response_to_type,
            :created_at => @activity.created_at,
            :updated_at => @activity.updated_at
          }

          a_request(:post, Redu::Application.config.vis_client[:url]).
            with(:body => params.to_json,
                 :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                              'Content-Type'=>'application/json'}).should have_been_made
        end

      end

      context "and status is type of Help" do
        before do
          WebMock.disable_net_connect!
          ActiveRecord::Observer.with_observers(:status_observer) do
            @stub = stub_request(:post, Redu::Application.config.vis_client[:url]).
              with(:headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                                'Content-Type'=>'application/json'}).
                                to_return(:status => 200, :body => "", :headers => {})

            @help = Factory(:help, :statusable => @lecture,
                            :user => @poster)
          end
        end

        it "send information of core to visualization" do
          params = {
            :lecture_id => @help.statusable_id,
            :subject_id => @help.statusable.subject.id,
            :space_id => @help.statusable.subject.space.id,
            :course_id => @help.statusable.subject.space.course.id,
            :user_id => @help.user_id,
            :type => @help.type.downcase,
            :status_id => @help.id,
            :statusable_id => @help.statusable_id,
            :statusable_type => @help.statusable_type,
            :in_response_to_id => @help.in_response_to_id,
            :in_response_to_type => @help.in_response_to_type,
            :created_at => @help.created_at,
            :updated_at => @help.updated_at
          }

          a_request(:post, Redu::Application.config.vis_client[:url]).
            with(:body => params.to_json,
                 :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                              'Content-Type'=>'application/json'}).should have_been_made
        end
      end

      context "and status is type of Answer" do

        context "and Statusable is type of Activity" do
          before do
            @activity = Factory(:activity, :statusable => @lecture,
                                :user => @poster)

            WebMock.disable_net_connect!
            ActiveRecord::Observer.with_observers(:status_observer) do
              @stub = stub_request(:post, Redu::Application.config.vis_client[:url]).
                with(:headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                                  'Content-Type'=>'application/json'}).
                                  to_return(:status => 200, :body => "", :headers => {})

              @answer = Factory(:answer, :statusable => @activity,
                              :user => @poster)
            end
          end

          it "send information of core to visualization" do
            params = {
              :lecture_id => @activity.statusable_id,
              :subject_id => @activity.statusable.subject.id,
              :space_id => @activity.statusable.subject.space.id,
              :course_id => @activity.statusable.subject.space.course.id,
              :user_id => @answer.user_id,
              :type => "answered_activity",
              :status_id => @answer.id,
              :statusable_id => @answer.statusable_id,
              :statusable_type => @answer.statusable_type,
              :in_response_to_id => @answer.in_response_to_id,
              :in_response_to_type => @answer.in_response_to_type,
              :created_at => @answer.created_at,
              :updated_at => @answer.updated_at
            }

            a_request(:post, Redu::Application.config.vis_client[:url]).
              with(:body => params.to_json,
                   :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                                'Content-Type'=>'application/json'}).should have_been_made
          end
        end

        context "and statusable is type of Help" do
          before do
            @help = Factory(:help, :statusable => @lecture,
                            :user => @poster)

            WebMock.disable_net_connect!
            ActiveRecord::Observer.with_observers(:status_observer) do
              @stub = stub_request(:post, Redu::Application.config.vis_client[:url]).
                with(:headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                                  'Content-Type'=>'application/json'}).
                                  to_return(:status => 200, :body => "", :headers => {})

              @answer = Factory(:answer, :statusable => @help,
                               :user => @poster)
            end
          end

          it "send information of core to visualization" do
            params = {
              :lecture_id => @help.statusable_id,
              :subject_id => @help.statusable.subject.id,
              :space_id => @help.statusable.subject.space.id,
              :course_id => @help.statusable.subject.space.course.id,
              :user_id => @answer.user_id,
              :type => "answered_help",
              :status_id => @answer.id,
              :statusable_id => @answer.statusable_id,
              :statusable_type => @answer.statusable_type,
              :in_response_to_id => @answer.in_response_to_id,
              :in_response_to_type => @answer.in_response_to_type,
              :created_at => @answer.created_at,
              :updated_at => @answer.updated_at
            }

            a_request(:post, Redu::Application.config.vis_client[:url]).
              with(:body => params.to_json,
                   :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                                'Content-Type'=>'application/json'}).should have_been_made
          end

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

        WebMock.disable_net_connect!
        ActiveRecord::Observer.with_observers(:status_observer) do
         @stub = stub_request(:post, Redu::Application.config.vis_client[:url]).
            with(:headers => {'Authorization'=>['JOjLeRjcK', 'core-team'], 'Content-Type'=>'application/json'}).
                 to_return(:status => 200, :body => "", :headers => {})


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

      it "send information of core do visualization" do
        params = {
          :lecture_id => nil,
          :subject_id => nil,
          :space_id => @activity.statusable_id,
          :course_id => @activity.statusable.course.id,
          :user_id => @activity.user_id,
          :type => "activity",
          :status_id => @activity.id,
          :statusable_id => @activity.statusable_id,
          :statusable_type => @activity.statusable_type,
          :in_response_to_id => @activity.in_response_to_id,
          :in_response_to_type => @activity.in_response_to_type,
          :created_at => @activity.created_at,
          :updated_at => @activity.updated_at,
        }

        a_request(:post, Redu::Application.config.vis_client[:url]).
          with(:body => params.to_json,
               :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                            'Content-Type'=>'application/json'}).should have_been_made

      end

      context "and status is type of Answer" do

        context "and Statusable is type of Activity" do
          before do
            @activity = Factory(:activity, :statusable => @space,
                                :user => @poster)

            WebMock.disable_net_connect!
            ActiveRecord::Observer.with_observers(:status_observer) do
              @stub = stub_request(:post, Redu::Application.config.vis_client[:url]).
                with(:headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                                  'Content-Type'=>'application/json'}).
                                  to_return(:status => 200, :body => "", :headers => {})

              @answer = Factory(:answer, :statusable => @activity,
                                :user => @poster)
            end
          end

          it "send information of core to visualization" do
            params = {
              :lecture_id => nil,
              :subject_id => nil,
              :space_id => @activity.statusable.id,
              :course_id => @activity.statusable.course.id,
              :user_id => @answer.user_id,
              :type => "answered_activity",
              :status_id => @answer.id,
              :statusable_id => @answer.statusable_id,
              :statusable_type => @answer.statusable_type,
              :in_response_to_id => @answer.in_response_to_id,
              :in_response_to_type => @answer.in_response_to_type,
              :created_at => @answer.created_at,
              :updated_at => @answer.updated_at
            }

            a_request(:post, Redu::Application.config.vis_client[:url]).
              with(:body => params.to_json,
                   :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                                'Content-Type'=>'application/json'}).should have_been_made
          end
        end
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

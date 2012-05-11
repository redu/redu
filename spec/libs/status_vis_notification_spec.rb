require 'spec_helper'

describe StatusVisNotification do

  context "after create a status" do

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

        it "send information of core to visualization" do
          params = fill_params_by_lecture(@activity)

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
          params = fill_params_by_lecture(@help)

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
            params = fill_params_by_lecture_type_answer(@activity, @answer, "answered_activity")

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
            params = fill_params_by_lecture_type_answer(@help, @answer, "answered_help")

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

        WebMock.disable_net_connect!
        ActiveRecord::Observer.with_observers(:status_observer) do
          @stub = stub_request(:post, Redu::Application.config.vis_client[:url]).
            with(:headers => {'Authorization'=>['JOjLeRjcK', 'core-team'], 'Content-Type'=>'application/json'}).
            to_return(:status => 200, :body => "", :headers => {})


          @activity = Factory(:activity, :statusable => @space,
                              :user => @poster)

        end
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
            params = fill_params_by_space(@activity, @answer, "answered_activity")

            a_request(:post, Redu::Application.config.vis_client[:url]).
              with(:body => params.to_json,
                   :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                                'Content-Type'=>'application/json'}).should have_been_made
          end
        end
      end
    end
  end
end

def fill_params_by_lecture(status)
  params = {
    :lecture_id => status.statusable_id,
    :subject_id => status.statusable.subject.id,
    :space_id => status.statusable.subject.space.id,
    :course_id => status.statusable.subject.space.course.id,
    :user_id => status.user_id,
    :type => status.type.downcase,
    :status_id => status.id,
    :statusable_id => status.statusable_id,
    :statusable_type => status.statusable_type,
    :in_response_to_id => status.in_response_to_id,
    :in_response_to_type => status.in_response_to_type,
    :created_at => status.created_at,
    :updated_at => status.updated_at }
end

def fill_params_by_lecture_type_answer(status, answer, type)
  params = {
    :lecture_id => status.statusable_id,
    :subject_id => status.statusable.subject.id,
    :space_id => status.statusable.subject.space.id,
    :course_id => status.statusable.subject.space.course.id,
    :user_id => answer.user_id,
    :type => type,
    :status_id => answer.id,
    :statusable_id => answer.statusable_id,
    :statusable_type => answer.statusable_type,
    :in_response_to_id => answer.in_response_to_id,
    :in_response_to_type => answer.in_response_to_type,
    :created_at => answer.created_at,
    :updated_at => answer.updated_at
  }
end

def fill_params_by_space(status, answer, type)
  params = {
    :lecture_id => nil,
    :subject_id => nil,
    :space_id => status.statusable.id,
    :course_id => status.statusable.course.id,
    :user_id => answer.user_id,
    :type => type,
    :status_id => answer.id,
    :statusable_id => answer.statusable_id,
    :statusable_type => answer.statusable_type,
    :in_response_to_id => answer.in_response_to_id,
    :in_response_to_type => answer.in_response_to_type,
    :created_at => answer.created_at,
    :updated_at => answer.updated_at
  }
end

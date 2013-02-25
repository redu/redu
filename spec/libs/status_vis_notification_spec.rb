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
            vis_stub_request

            @activity = Factory(:activity, :statusable => @lecture,
                                :user => @poster)
          end
        end

        xit "send information of core to visualization" do
          params = fill_params_by_lecture(@activity, "activity")

          vis_a_request(params).should have_been_made
       end

      end

      context "and status is type of Help" do
        before do
          WebMock.disable_net_connect!
          ActiveRecord::Observer.with_observers(:status_observer) do
            vis_stub_request

            @help = Factory(:help, :statusable => @lecture,
                            :user => @poster)
          end
        end

        xit "send information of core to visualization" do
          params = fill_params_by_lecture(@help, "help")

          vis_a_request(params).should have_been_made
        end
      end

      context "and status is type of Answer" do

        context "and Statusable is type of Activity" do
          before do
            @activity = Factory(:activity, :statusable => @lecture,
                                :user => @poster)

            WebMock.disable_net_connect!
            ActiveRecord::Observer.with_observers(:status_observer) do
              vis_stub_request

              @answer = Factory(:answer, :statusable => @activity,
                                :user => @poster)
            end
          end

          xit "send information of core to visualization" do
            params = fill_params_by_lecture_type_answer(@activity, @answer, "answered_activity")

            vis_a_request(params).should have_been_made
          end
        end

        context "and statusable is type of Help" do
          before do
            @help = Factory(:help, :statusable => @lecture,
                            :user => @poster)

            WebMock.disable_net_connect!
            ActiveRecord::Observer.with_observers(:status_observer) do
              vis_stub_request

              @answer = Factory(:answer, :statusable => @help,
                                :user => @poster)
            end
          end

          xit "send information of core to visualization" do
            params = fill_params_by_lecture_type_answer(@help, @answer, "answered_help")

            vis_a_request(params).should have_been_made
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
          vis_stub_request

          @activity = Factory(:activity, :statusable => @space,
                              :user => @poster)
        end
      end

      xit "send information of core do visualization" do
        params = fill_params_by_space(@activity, "activity")

        vis_a_request(params).should have_been_made
      end

      context "and status is type of Answer" do

        context "and Statusable is type of Activity" do
          before do
            @activity = Factory(:activity, :statusable => @space,
                                :user => @poster)

            WebMock.disable_net_connect!
            ActiveRecord::Observer.with_observers(:status_observer) do
              vis_stub_request

              @answer = Factory(:answer, :statusable => @activity,
                                :user => @poster)
            end
          end

          xit "send information of core to visualization" do
            params = fill_params_by_space_type_answer(@activity, @answer, "answered_activity")

            vis_a_request(params).should have_been_made
          end
        end
      end
    end
  end

  context "after destroy a status" do
    before do
      @environment = Factory(:environment)
      @course = Factory(:course, :environment => @environment,
                        :owner => @environment.owner)
      @space = Factory(:space, :course => @course,
                       :owner => @environment.owner)
      @user = @environment.owner
      @poster = Factory(:user)
      @course.join(@poster)
      WebMock.disable_net_connect!
    end

    context "when region is Space" do
      let(:activity_space) { Factory(:activity, :statusable => @space,
                                     :user => @poster) }
      let(:answer_activity_space) { Factory(:answer, :user => @poster,
                                            :in_response_to => activity_space,
                                            :statusable => activity_space) }

      xit "and status is Activity should send notification to visualization" do
        ActiveRecord::Observer.with_observers(:vis_status_observer) do
          vis_stub_request
          activity_space.destroy
        end

        params = fill_params_by_space(activity_space, "remove_activity")
        vis_a_request(params).should have_been_made
      end

      xit "and status is Answer and statusable is Activity should send
        notification to visualization" do
        ActiveRecord::Observer.with_observers(:vis_status_observer) do
          vis_stub_request
          answer_activity_space.destroy
        end

        params = fill_params_by_space_type_answer(activity_space,
                  answer_activity_space, "remove_answered_activity")

        vis_a_request(params).should have_been_made
      end
    end

    context "when region is Lecture" do
      before do
        @subject = Factory(:subject, :owner => @poster, :space => @space)
        @lecture = Factory(:lecture, :subject => @subject,
                           :owner => @environment.owner)
      end

      let(:activity_lecture) {Factory(:activity, :statusable => @lecture,
                                      :user => @poster)}
      let(:help_lecture) {Factory(:help, :statusable => @lecture,
                                      :user => @poster)}
      let(:answer_activity_lecture) { Factory(:answer, :user => @poter,
                                              :in_response_to => activity_lecture,
                                              :statusable => activity_lecture)}
      let(:answer_help_lecture) { Factory(:answer, :user => @poter,
                                              :in_response_to => help_lecture,
                                              :statusable => help_lecture)}


      xit "and status is Activity should send notification to visualization" do
        ActiveRecord::Observer.with_observers(:vis_status_observer) do
          vis_stub_request
          activity_lecture.destroy
        end

        params = fill_params_by_lecture(activity_lecture,
                                        "remove_activity")

        vis_a_request(params).should have_been_made

      end

      xit "and status is Help should send notification to visualization" do
        ActiveRecord::Observer.with_observers(:vis_status_observer) do
          vis_stub_request
          help_lecture.destroy
        end

        params = fill_params_by_lecture(help_lecture, "remove_help")

        vis_a_request(params).should have_been_made
      end

      context "and status is Answer" do
        xit "and statusable is Activity should send notification
        to visualization" do
          ActiveRecord::Observer.with_observers(:vis_status_observer) do
            vis_stub_request
            answer_activity_lecture.destroy
          end

          params = fill_params_by_lecture_type_answer(activity_lecture,
                      answer_activity_lecture, "remove_answered_activity")

          vis_a_request(params).should have_been_made
        end

        xit "and statusable is Help should send notification to visualization" do
          ActiveRecord::Observer.with_observers(:vis_status_observer) do
            vis_stub_request
            answer_help_lecture.destroy
          end

          params = fill_params_by_lecture_type_answer(help_lecture,
                      answer_help_lecture, "remove_answered_help")

          vis_a_request(params).should have_been_made
        end
      end
    end
  end

  def fill_params_by_lecture(status, type)
    params = {
      :lecture_id => status.statusable_id,
      :subject_id => status.statusable.subject.id,
      :space_id => status.statusable.subject.space.id,
      :course_id => status.statusable.subject.space.course.id,
      :user_id => status.user_id,
      :type => type,
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

  def fill_params_by_space(status, type)
    params = {
      :lecture_id => nil,
      :subject_id => nil,
      :space_id => status.statusable_id,
      :course_id => status.statusable.course.id,
      :user_id => status.user_id,
      :type => type,
      :status_id => status.id,
      :statusable_id => status.statusable_id,
      :statusable_type => status.statusable_type,
      :in_response_to_id => status.in_response_to_id,
      :in_response_to_type => status.in_response_to_type,
      :created_at => status.created_at,
      :updated_at => status.updated_at,
    }
  end

  def fill_params_by_space_type_answer(status, answer, type)
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
end

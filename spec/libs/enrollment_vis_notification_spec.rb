require 'spec_helper'

describe EnrollmentVisNotification do
  context "in a Course" do
    before(:each) do
      @environment_owner = Factory(:user)
      @environment = Factory(:environment, :owner => @environment_owner)
    end

    subject { Factory(:course, :owner => @environment_owner,
                      :environment => @environment) }

    context "when joining an user" do
      before do
        @space = Factory(:space, :course => subject)
        @subj = Factory(:subject, :space => @space,
                        :owner => subject.owner,
                        :finalized => true)
        @user = Factory(:user)
        subject.reload
      end

      it "should send a notification to vis" do
        WebMock.disable_net_connect!
        stubing_request

        subj2 = Factory(:subject, :space => @space,
                        :owner => subject.owner,
                        :finalized => true)

        enrollments = []
        subject.join(@user)
        enrollments << @user.get_association_with(@subj)
        enrollments << @user.get_association_with(subj2)

        enrollments.each do |enroll|
          params = fill_params(enroll, "enrollment")

          webmock_request(params).should have_been_made
        end
      end
    end

    context "removes an user (unjoin)" do
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

      it "should send a remove enrollment notification and a remove subject finalized notification to vis" do
        WebMock.reset!
        WebMock.disable_net_connect!
        stubing_request

        enrollments = []
        subject.users.each do |user|
          enrollment = user.get_association_with(@sub)
          if enrollment
            enrollment.grade = 100
            enrollment.graduaded = true
            enrollment.save
            enrollments << enrollment
          end
          enrollment_2 = user.get_association_with(@sub_2)
          enrollments << enrollment_2 if enrollment_2
        end
        subject.unjoin(@user)

        enrollments.each do |enroll|

          params = fill_params(enroll, "remove_enrollment")

          webmock_request(params).should have_been_made

          if enroll.graduaded
            params = fill_params(enroll, "remove_subject_finalized")
            webmock_request(params).should have_been_made
          end
        end
      end
    end
  end

  context "in a Status Observer" do
    before do
      subject_owner = Factory(:user)
      @space = Factory(:space)
      @space.course.join subject_owner
      @sub = Factory(:subject, :owner => subject_owner,
                     :space => @space)
    end

    subject { Factory(:enrollment, :subject => @sub) }


    context "when updating" do
      let :lectures do
        3.times.collect do
          Factory(:lecture, :subject => @sub, :owner => @sub.owner)
        end
      end

      before do
        WebMock.disable_net_connect!
        stubing_request
      end

      it "when grade is not full (< 100) and became full should send a 'subject_finalized' notification to vis" do
        ActiveRecord::Observer.with_observers(:enrollment_observer) do
          lectures
          subject.asset_reports.each { |a| a.done = true; a.save }
          subject.update_grade!
        end

        params = fill_params(subject, "subject_finalized")

        webmock_request(params).should have_been_made
      end

      it "when grade is not full (<100) and continue not full (<100) should not send a notification to vis" do
        ActiveRecord::Observer.with_observers(:enrollment_observer) do
          lectures
          subject.asset_reports[0..1].each { |a| a.done = true; a.save }
          subject.update_grade!
        end

        params = fill_params(subject, "subject_finalized")

        webmock_request(params).should_not have_been_made
      end

      context "and grade is filled" do
        it "when grade is already full (100) should not send a notification to vis" do
          lectures
          subject.asset_reports.each { |a| a.done = true; a.save }
          subject.update_grade!

          ActiveRecord::Observer.with_observers(:enrollment_observer) do
            subject.role = 2
            subject.save
          end

          params = fill_params(subject, "subject_finalized")

          webmock_request(params).should_not have_been_made
        end

        it "when grade is updated for less then 100 should send a 'removed_subject_finalized' notification to vis" do
          lectures
          subject.asset_reports.each { |a| a.done = true; a.save }
          subject.update_grade!

          ActiveRecord::Observer.with_observers(:enrollment_observer) do
            subject.asset_reports[0].done = false;
            subject.asset_reports[0].save
            subject.update_grade!
          end

          params = fill_params(subject, "remove_subject_finalized")

          webmock_request(params).should have_been_made
        end
      end
    end
  end

  def stubing_request
    stub_request(:post, Redu::Application.config.vis_client[:url]).
      with(:headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                        'Content-Type'=>'application/json'}).
                        to_return(:status => 200, :body => "", :headers => {})
  end

  def webmock_request(params)
    a_request(:post, Redu::Application.config.vis_client[:url]).
      with(:body => params.to_json,
           :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                        'Content-Type'=>'application/json'})
  end

  def fill_params(enroll, type)
    params = {
      :lecture_id => nil,
      :subject_id => enroll.subject_id,
      :space_id => enroll.subject.space_id,
      :course_id => enroll.subject.space.course_id,
      :user_id => enroll.user_id,
      :type => type,
      :status_id => nil,
      :statusable_id => nil,
      :statusable_type => nil,
      :in_response_to_id => nil,
      :in_response_to_type => nil,
      :created_at => enroll.created_at,
      :updated_at => enroll.updated_at
    }
  end
end



require 'spec_helper'

describe EnrollmentVisNotification do
  let(:environment_owner) { Factory(:user) }
  let(:environment) { Factory(:environment, :owner => environment_owner) }
  let(:user) { Factory(:user) }

  context "in a Course" do
    let(:space) { Factory(:space, :course => subject) }
    subject { Factory(:course, :owner => environment_owner,
                      :environment => environment) }

    before do
      @subj = Factory(:subject, :space => space,
                      :owner => subject.owner, :finalized => true)
      @subj2 = Factory(:subject, :space => space,
                       :owner => subject.owner, :finalized => true)
    end

    context "when an user is joining and there is a subject" do

      it "should send a notification to vis" do
        WebMock.disable_net_connect!
        vis_stub_request

        enrollments = []
        subject.join(user)
        enrollments << user.get_association_with(@subj)
        enrollments << user.get_association_with(@subj2)

        enrollments.each do |enroll|
          params = fill_params(enroll, "enrollment")
          vis_a_request(params).should have_been_made
        end
      end
    end

    context "removes an user (unjoin)" do
      let(:space_2) { Factory(:space, :course => subject) }

      before do
       @subj2.space = space_2
       @subj2.save

       subject.join user
      end

      it "should send a remove enrollment notification and a remove subject finalized notification to vis" do
        WebMock.reset!
        WebMock.disable_net_connect!

        vis_stub_request

        enrollments = []
        enrollment = user.get_association_with(@sub)
        if enrollment
          enrollment.grade = 100
          enrollment.graduated = true
          enrollment.save
          enrollments << enrollment
        end

        enrollment_2 = user.get_association_with(@sub2)
        enrollments << enrollment_2 if enrollment_2

        subject.unjoin user

        enrollments.each do |enroll|
          params = fill_params(enroll, "remove_enrollment")
          vis_a_request(params).should have_been_made

          if enroll.graduated
            params = fill_params(enroll, "remove_subject_finalized")
            vis_a_request(params).should have_been_made
          end
        end
      end

    end
  end

  context "in a Enrollment Observer" do
    let(:subj) { Factory(:subject,
                         :owner => environment_owner) }

    subject { Factory(:enrollment, :subject => subj, :user => user) }

    context "when updating" do
      let :lectures do
        3.times.collect do
          Factory(:lecture, :subject => subj, :owner => subj.owner)
        end
      end

      before do
        WebMock.disable_net_connect!
        vis_stub_request
      end

      it "when grade is not full (< 100) and became full should send a 'subject_finalized' notification to vis" do
        ActiveRecord::Observer.with_observers(:vis_enrollment_observer) do
          lectures
          subject.asset_reports.each { |a| a.done = true; a.save }
          subject.update_grade!
        end

        params = fill_params(subject, "subject_finalized")
        vis_a_request(params).should have_been_made
      end

      it "when grade is not full (<100) and continue not full (<100) should not send a notification to vis" do
        ActiveRecord::Observer.with_observers(:vis_enrollment_observer) do
          lectures
          subject.asset_reports[0..1].each { |a| a.done = true; a.save }
          subject.update_grade!
        end

        params = fill_params(subject, "subject_finalized")
        vis_a_request(params).should_not have_been_made
      end

      context "and grade is filled" do
        it "when grade is already full (100) should not send a notification to vis" do
          lectures
          subject.asset_reports.each { |a| a.done = true; a.save }
          subject.update_grade!

          ActiveRecord::Observer.with_observers(:vis_enrollment_observer) do
            subject.role = 4
            subject.save
          end

          params = fill_params(subject, "subject_finalized")
          vis_a_request(params).should_not have_been_made
        end

        it "when grade is updated for less then 100 should send a 'removed_subject_finalized' notification to vis" do
          lectures
          subject.asset_reports.each { |a| a.done = true; a.save }
          subject.update_grade!

          ActiveRecord::Observer.with_observers(:vis_enrollment_observer) do
            subject.asset_reports[0].done = false;
            subject.asset_reports[0].save
            subject.update_grade!
          end

          params = fill_params(subject, "remove_subject_finalized")

          vis_a_request(params).should have_been_made
        end
      end
    end
  end

  context "when User is removed" do
    before do
      @user = Factory(:user)
      @space = Factory(:space)

      @space.course.join @user
      @space.course.reload
    end

    context "whit enrollments" do
      before do
        sub1 = Factory(:subject, :space => @space, :finalized => true)
        sub2 = Factory(:subject, :space => @space, :finalized => true)

        Factory(:enrollment, :subject => sub1, :user => @user)
        Factory(:enrollment, :subject => sub2, :user => @user)

        @enrolls = @user.enrollments
      end

      it "should send vis notification 'remove_enrollment'" do
        WebMock.disable_net_connect!
        vis_stub_request

        ActiveRecord::Observer.with_observers(:vis_user_observer) do
          @user.destroy
        end

        @enrolls.each do |enroll|
          params = fill_params(enroll, "remove_enrollment")

          vis_a_request(params).should have_been_made
        end
      end

      it "should send any vis notification 'remove_subject_finalized'" do
        WebMock.disable_net_connect!
        vis_stub_request

        ActiveRecord::Observer.with_observers(:vis_user_observer) do
          @user.destroy
        end

        @enrolls.each do |enroll|
          params = fill_params(enroll, "remove_subject_finalized")

          vis_a_request(params).should_not have_been_made
        end
      end

      context "with subjects finalized" do
        before do
          sub3 = Factory(:subject, :space => @space, :finalized => true)
          Factory(:enrollment, :subject => sub3, :user => @user, :graduated => true)
        end

        it "should send vis notification 'remove_subject_finalized'" do
          WebMock.disable_net_connect!
          vis_stub_request

          ActiveRecord::Observer.with_observers(:vis_user_observer) do
            @user.destroy
          end

          @enrolls.each do |enroll|
            if enroll.graduated
              params = fill_params(enroll, "remove_subject_finalized")

              vis_a_request(params).should have_been_made
            end
          end
        end
      end
    end
  end

  context "when a Subject is updated to finalized = true" do
    let(:course) { Factory(:course, :owner => environment_owner) }
    let(:space) { Factory(:space, :course => course,
                          :owner => environment_owner) }

    subject { Factory(:subject, :space => space,
                      :owner => environment_owner) }

    before do
      5.times do
        course.join Factory(:user)
      end
    end


    it "should send notifications about all users" do
      WebMock.disable_net_connect!
      vis_stub_request

      ActiveRecord::Observer.
        with_observers(:subject_observer) do
        subject.finalized = true
        subject.save
      end

      subject.enrollments.each do |enroll|
        params = fill_params(enroll, "enrollment")
        vis_a_request(params).should have_been_made
      end
    end
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



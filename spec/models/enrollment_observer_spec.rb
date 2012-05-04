require "spec_helper"

describe EnrollmentObserver do
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
      @stub = stub_request(:post, Redu::Application.config.vis_client[:url]).
        with(:headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                          'Content-Type'=>'application/json'}).
                          to_return(:status => 200, :body => "", :headers => {})
    end

    it "when grade is not full (< 100) and became full should send a 'subject_finalized' notification to vis" do
     ActiveRecord::Observer.with_observers(:enrollment_observer) do
        lectures
        subject.asset_reports.each { |a| a.done = true; a.save }
        subject.update_grade!
      end

      params = fill_params(subject)

      a_request(:post, Redu::Application.config.vis_client[:url]).
        with(:body => params.to_json,
             :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                          'Content-Type'=>'application/json'}).should have_been_made
    end

    it "when grade is not full (<100) and continue not full (<100) should not send a notification to vis" do
      ActiveRecord::Observer.with_observers(:enrollment_observer) do
        lectures
        subject.asset_reports[0..1].each { |a| a.done = true; a.save }
        subject.update_grade!
      end

      params = fill_params(subject)

      a_request(:post, Redu::Application.config.vis_client[:url]).
        with(:body => params.to_json,
             :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                          'Content-Type'=>'application/json'}).should_not have_been_made

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

        params = fill_params(subject)

        a_request(:post, Redu::Application.config.vis_client[:url]).
          with(:body => params.to_json,
               :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                            'Content-Type'=>'application/json'}).should_not have_been_made
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

        a_request(:post, Redu::Application.config.vis_client[:url]).
          with(:body => params.to_json,
               :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                            'Content-Type'=>'application/json'}).should have_been_made
      end
    end

  end

  def fill_params(enrollment, type = "subject_finalized")
    params = {
      :user_id => enrollment.user_id,
      :lecture_id => nil,
      :subject_id => enrollment.subject_id,
      :space_id => enrollment.subject.space.id,
      :course_id => enrollment.subject.space.course.id,
      :type => type,
      :status_id => nil,
      :statusable_id => nil,
      :statusable_type => nil,
      :in_response_to_id => nil,
      :in_response_to_type => nil,
      :created_at => enrollment.created_at,
      :updated_at => enrollment.updated_at
    }
  end
end

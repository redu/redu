require 'spec_helper'

describe VisUserObserver do
  subject { Factory(:user) }

  context "when are enrollments" do
    let(:subj) { Factory(:subject, :owner => subject) }
    let(:enrollment) do
      Factory(:enrollment, :subject => subj, :user => subject)
    end
    let(:subj2) { Factory(:subject, :space => subj.space, :owner => subject) }
    let(:enrollment2) do
      Factory(:enrollment, :subject => subj2, :user => subject)
    end

    let!(:enrollments) do
      [enrollment, enrollment2]
    end

    it "should call VisClient.notify_delayed for all enrollments" do
      VisClient.should_receive(:notify_delayed).
        with("/hierarchy_notifications.json",
             "remove_enrollment", enrollments)

      VisClient.should_receive(:notify_delayed).
        with("/hierarchy_notifications.json",
             "remove_subject_finalized", [])

      ActiveRecord::Observer.with_observers(:vis_user_observer) do
        subject.destroy
      end
    end

    context "when some of the enrollments are finalized" do
      let(:subj3) { Factory(:subject, :space => subj.space, :owner => subject) }
      let(:enrollment3) do
        Factory(:enrollment, :subject => subj3, :user => subject,
                :graduated => true, :grade => 100)
      end

      let(:enrollments) do
        [enrollment, enrollment2, enrollment3]
      end

      it "should call VisClient.notify_delayed for all finalized enrollments" do
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json",
               "remove_enrollment", enrollments)
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json",
               "remove_subject_finalized", [enrollment3])

        ActiveRecord::Observer.with_observers(:vis_user_observer) do
          subject.destroy
        end
      end
    end

  end
end

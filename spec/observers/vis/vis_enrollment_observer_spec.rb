require 'spec_helper'

describe VisEnrollmentObserver do
  let(:subj) { Factory(:subject) }
  subject { Factory(:enrollment, :subject => subj, :user => subj.owner) }

  describe "before update" do

    context "when finalizing and unfinalizing a subject" do
      let! :lectures do
        3.times.collect do
          Factory(:lecture, :subject => subj, :owner => subj.owner)
        end
      end

      let(:finalize_lectures) do
        subject.asset_reports.each { |as| as.done = true; as.save }
      end

      let(:finalize_some_lectures) do
        subject.asset_reports.limit(2).each { |as| as.done = true; as.save }
      end

      it "should call VisClient.notify_delayed when all lectures are done" do
        finalize_lectures
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json", "subject_finalized", subject)

        ActiveRecord::Observer.with_observers(:vis_enrollment_observer) do
          subject.update_grade!
        end
      end

      it "shouldn't call VisClient.notify_delayed when all lectures aren't done" do
        finalize_some_lectures
        VisClient.should_not_receive(:notify_delayed)

        ActiveRecord::Observer.with_observers(:vis_enrollment_observer) do
          subject.update_grade!
        end
      end

      it "shouldn't call notify_delayed when grade is already full" do
        finalize_lectures
        VisClient.should_not_receive(:notify_delayed)
        ActiveRecord::Observer.with_observers(:vis_enrollment_observer) do
          subject.role = 4
          subject.save
        end
      end

      it "should call notify_delayed when grade is unfinalized" do
        finalize_lectures
        subject.update_grade!
        subject.asset_reports[0].done = false
        subject.asset_reports[0].save

        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json",
               "remove_subject_finalized", subject)

        ActiveRecord::Observer.with_observers(:vis_enrollment_observer) do
          subject.update_grade!
        end
      end

    end
  end
end

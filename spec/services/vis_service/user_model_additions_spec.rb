require 'spec_helper'

module VisService
  describe User do
    subject { Factory(:user) }

    context "when are enrollments" do
      let!(:enrollments) do
        FactoryGirl.create_list(:enrollment, 2, :user => subject)
      end

      it "should call VisClient.notify_delayed for all enrollments" do
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json",
               "remove_enrollment", enrollments)

        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json",
               "remove_subject_finalized", [])

        subject.destroy
      end

      context "when some of the enrollments are finalized" do
        let!(:enrollments) do
          FactoryGirl.create_list(:enrollment, 3, :user => subject)
        end

        let(:finalized_enrollments) do
          enrollment = enrollments.first
          enrollment.update_attributes(:graduated => true, :grade => 100)
          [enrollment]
        end

        it "should call VisClient.notify_delayed for all finalized enrollments" do
          VisClient.should_receive(:notify_delayed).
            with("/hierarchy_notifications.json",
                 "remove_enrollment", enrollments)
          VisClient.should_receive(:notify_delayed).
            with("/hierarchy_notifications.json",
                 "remove_subject_finalized", finalized_enrollments)

          subject.destroy
        end
      end
    end
  end
end

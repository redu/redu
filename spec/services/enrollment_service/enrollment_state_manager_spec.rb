require 'spec_helper'

module EnrollmentService
  describe EnrollmentStateManager do
    subject { EnrollmentStateManager.new(enrollments) }
    let(:facade) { mock('Facade') }
    let(:enrollments) do
      FactoryGirl.
        create_list(:enrollment, 3, :graduated => false, :subject => nil)
    end

    context "#enrollments" do
      it "should transform single record into collection" do
        enrollment = mock_model('Enrollment')
        EnrollmentStateManager.new(enrollment).enrollments.should ==
          [enrollment]
      end
    end

    context "#facade" do
      before do
        subject.stub(:service_facade).and_return(facade)
      end

      it "should call #notify_subject_finalized when all enrollments are done" do
        facade.should_receive(:notify_subject_finalized).with(enrollments)

        subject.notify_vis_if_enrollment_change do
          toggle_graduated(enrollments)
        end
      end

      it "should call #notify_remove_subject_finalized if enrollments aren't done" do
        facade.should_receive(:notify_remove_subject_finalized).with(enrollments)

        toggle_graduated(enrollments)
        subject.notify_vis_if_enrollment_change do
          toggle_graduated(enrollments)
        end
      end

      it "should call both #notify_subject_finalized and " + \
         "#notify_remove_subject_finalized" do
        finalized = enrollments[1..-1]
        unfinalized = enrollments.first

        facade.should_receive(:notify_subject_finalized).with(finalized)
        facade.should_receive(:notify_remove_subject_finalized).with([unfinalized])

        toggle_graduated(unfinalized)
        subject.notify_vis_if_enrollment_change do
          toggle_graduated(unfinalized)
          toggle_graduated(finalized)
        end
      end

      it "shouldn't call anything if graduated don't change" do
        facade.should_not_receive(:notify_subject_finalized)
        facade.should_not_receive(:notify_remove_subject_finalized)

        subject.notify_vis_if_enrollment_change
      end

      def toggle_graduated(enrollments)
        enrollments = enrollments.respond_to?(:map) ? enrollments : [enrollments]
        enrollments.map { |e| e.toggle(:graduated) }
      end
    end
  end
end

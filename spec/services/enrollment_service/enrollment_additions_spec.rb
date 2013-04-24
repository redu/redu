require 'spec_helper'

module EnrollmentService
  describe Enrollment do
    subject { Factory(:enrollment, :grade => 0, :graduated => false) }
    let(:facade) { mock('Facade') }
    before { subject.stub(:service_facade).and_return(facade) }

    context "#update_grade!" do

      it "should invoke Facade#update_grade!" do
        subject.send(:service_facade).should_receive(:update_grade).with(subject)
        subject.update_grade!
      end

      it "should call Facade#notify_subject_finalized when all lectures are done" do
        facade.stub(:update_grade) do |enrollment|
          enrollment.update_attributes(:grade => 100, :graduated => true)
        end

        facade.should_receive(:notify_subject_finalized).with(subject.reload)

        subject.update_grade!
      end

      it "shouldn't call Facade#notify_subject_finalized when all " + \
        "lecture aren't done" do
        facade.stub(:update_grade)
        facade.should_not_receive(:notify_subject_finalized)
        subject.update_grade!
      end

      it "should call Facade#notify_remove_subject_finalized when grade " + \
        "is unfinalized" do
        subject.update_attributes(:grade => 100, :graduated => true)

        facade.stub(:update_grade) do |enrollment|
          enrollment.update_attributes(:grade => 90, :graduated => false)
        end

        facade.should_receive(:notify_remove_subject_finalized).
          with(subject.reload)
        subject.update_grade!
      end
    end
  end
end

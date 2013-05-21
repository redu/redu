# -*- encoding : utf-8 -*-
require 'spec_helper'

module EnrollmentService
  describe Enrollment do
    subject { FactoryGirl.create(:enrollment, :grade => 0, :graduated => false) }
    let(:facade) { mock('Facade') }
    before { subject.stub(:service_facade).and_return(facade) }

    context "#update_grade!" do
      it "should invoke Facade#update_grade!" do
        subject.send(:service_facade).should_receive(:update_grade).with(subject)
        subject.update_grade!
      end
    end
  end
end

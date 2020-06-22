# -*- encoding : utf-8 -*-
require 'spec_helper'

module EnrollmentService
  module Jobs
    describe UpdateGradeJob do
      let(:enrollments) do
        FactoryBot.create_list(:enrollment, 2, subject: nil)
      end
      subject { UpdateGradeJob.new(enrollment: enrollments) }

      context "#execute" do
        it "should invoke Facade#update_grade" do
          subject.facade.should_receive(:update_grade).with(enrollments)
          subject.execute
        end
      end
    end
  end
end

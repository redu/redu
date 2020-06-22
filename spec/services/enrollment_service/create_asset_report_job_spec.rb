# -*- encoding : utf-8 -*-
require 'spec_helper'

module EnrollmentService
  module Jobs
    describe CreateAssetReportJob do
      let(:enrollments) do
        FactoryBot.create_list(:enrollment, 2, subject: nil)
      end
      let(:lectures) do
        FactoryBot.create_list(:lecture, 2, subject: nil)
      end
      subject do
        CreateAssetReportJob.new(enrollment: enrollments, lecture: lectures)
      end

      context "#execute" do
        it "should invoke Facade#create_asset_report" do
          subject.facade.should_receive(:create_asset_report).
            with(lectures: lectures, enrollments: enrollments)

          subject.execute
        end

        it "should return the enrollments" do
          subject.execute.should == { enrollments: enrollments }
        end
      end

      context "#build_next_job" do
        it "should initialize UpdateGradeJob" do
          UpdateGradeJob.should_receive(:new).with(enrollment: enrollments)
          subject.build_next_job({ enrollments: enrollments })
        end
      end
    end
  end
end

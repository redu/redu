# -*- encoding : utf-8 -*-
require 'spec_helper'

module EnrollmentService
  module Jobs
    describe CreateEnrollmentJob do
      let(:users) { 2.times.map { FactoryBot.create(:user) } }
      let(:subjects) do
        2.times.map { FactoryBot.create(:subject, space: nil, owner: nil) }
      end

      subject do
        CreateEnrollmentJob.
          new(user: users, subject: subjects, role: Role[:member])
      end

      it "should keep users ids" do
        subject.user_ids.should =~ users.map(&:id)
      end

      it "should keep subject ids" do
        subject.subject_ids.should =~ subjects.map(&:id)
      end

      context "#execute" do
        it "should invoke the Facade" do
          subject.facade.should_receive(:create_enrollment).
            with(subjects, users, role: Role[:member])
          subject.execute
        end

        it "should return the env with :enrollments" do
          enrollments = 3.times.map { mock_model('Enrollment') }
          subject.facade.stub(:create_enrollment).and_return(enrollments)
          subject.execute.should == { enrollments: enrollments }
        end
      end

      context "#build_next_job" do
        it "should initialize CreateAssetReportJob" do
          env = { enrollments: mock('Enrollments') }

          CreateAssetReportJob.should_receive(:new).
            with(lecture: [], enrollment: env[:enrollments])

          subject.build_next_job(env)
        end
      end
    end
  end
end

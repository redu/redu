# -*- encoding : utf-8 -*-
require 'spec_helper'

module EnrollmentService
  module Jobs
    describe LinkedJob do
      subject { LinkedJob.new }
      context "#perform" do
        it "should invoke #execute" do
          subject.should_receive(:execute)

          subject.perform
        end

        it "should invoke #build_next_job with the return value of #execute" do
          subject.stub(:execute).and_return({ :working => :holiday })
          subject.should_receive(:build_next_job).with({ :working => :holiday })

          subject.perform
        end

        it "should invoke #build_next_job with empty environment when " + \
           "#execute returns nil" do
          subject.should_receive(:build_next_job).with({})
          subject.perform
        end

        it "should invoke #enqueue with the next job" do
          next_job = mock('Job')
          subject.stub(:build_next_job).and_return(next_job)
          subject.should_receive(:enqueue).with(next_job)

          subject.perform
        end
      end
    end
  end
end

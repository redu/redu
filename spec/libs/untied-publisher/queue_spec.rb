require 'spec_helper'

module Untied
  module Publisher
    describe Queue do
      context "#enqueue" do
        subject { Untied::Publisher::Queue.new }
        let(:model) { mock_model('Enrollment') }

        it "should create a PublishEventJob" do
          job = mock('PublishEventJob')
          job.stub(:perform)
          PublishEventJob.should_receive(:new).
            with(:after_create, model.class.to_s, model).and_return(job)

          subject.enqueue(:after_create, model)
        end

        it "should enqueue the Job" do
          Delayed::Job.should_receive(:enqueue).
            with(an_instance_of(PublishEventJob), :queue => :vis)

          subject.enqueue(:after_create, model)
        end
      end
    end
  end
end

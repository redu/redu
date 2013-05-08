require 'spec_helper'

module Untied
  module Publisher
    describe BatchQueue do
      subject { BatchQueue.new }
      let(:enrollments) { 2.times.map { mock_model('Enrollment') } }

      context "#equeue" do
        it "should not enqueue right away" do
          Delayed::Job.should_not_receive(:enqueue)
          subject.enqueue(:after_create, enrollments.first)
        end
      end

      context "#commit" do
        let(:social_networks) { 2.times.map { mock_model('SocialNetwork') } }

        it "should create a EnqueuePublishEventJob" do
          job = mock('EnqueuePublishEventJob')
          job.stub(:perform)

          EnqueuePublishEventJob.should_receive(:new).
            with(:after_create, 'Enrollment', enrollments.map(&:id)).and_return(job)

          enrollments.map { |e| subject.enqueue(:after_create, e) }

          subject.commit
        end

        it "should enqueue the Job" do
          enrollments.map { |e| subject.enqueue(:after_create, e) }

          Delayed::Job.should_receive(:enqueue) do |job, options|
            job.event_name.should == :after_create
            job.class_name.should == 'Enrollment'
            job.ids.should =~ enrollments.map(&:id)
          end

          subject.commit
        end

        it "should enqueue multiple jobs when different class_name" do
          social_networks.map { |sn| subject.enqueue(:after_create, sn) }
          enrollments.map { |e| subject.enqueue(:after_create, e) }

          Delayed::Job.should_receive(:enqueue).twice

          subject.commit
        end

        it "should enqueue multiple jobs when different event_names" do
          social_networks.map { |sn| subject.enqueue(:after_destroy, sn) }
          enrollments.map { |e| subject.enqueue(:after_create, e) }

          Delayed::Job.should_receive(:enqueue).twice

          subject.commit
        end

        it "should not double commit events" do
          Delayed::Job.should_receive(:enqueue).once
          enrollments.map { |e| subject.enqueue(:after_create, e) }
          subject.commit
          subject.commit
        end

        it "should not double commit events when Exception is raised" do
          Delayed::Job.stub(:enqueue).and_raise Exception.new

          enrollments.map { |e| subject.enqueue(:after_create, e) }

          begin
            subject.commit
          rescue Exception; end

          subject.should be_empty
        end
      end
    end
  end
end

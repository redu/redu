# -*- encoding : utf-8 -*-
require 'spec_helper'

module Untied
  module Publisher
    describe QueueProxy do
      subject { QueueProxy.new }
      let(:batch_queue) { mock('Untied::Publisher::BatchQueue') }
      let(:simple_queue) { mock('Untied::Publisher::Queue') }

      context "#enqueue" do
        let(:enrollment) { mock_model('Enrollment') }
        before { enrollment.stub(:attributes).and_return({}) }

        it "should use BatchQueue for non after_destroy events" do
          subject.stub(:batch_queue).and_return(batch_queue)
          batch_queue.should_receive(:enqueue)
          subject.enqueue(:after_create, enrollment)
        end

        it "should use Queue otherwise" do
          subject.stub(:simple_queue).and_return(simple_queue)
          simple_queue.should_receive(:enqueue)
          subject.enqueue(:after_destroy, enrollment)
        end
      end

      context "#commit" do
        it "should invoke BatchQueue#commit" do
          subject.stub(:batch_queue).and_return(batch_queue)
          batch_queue.stub(:empty?).and_return(false)
          batch_queue.should_receive(:commit)
          subject.commit
        end
      end
    end
  end
end

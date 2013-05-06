require 'spec_helper'

module Untied
  module Publisher
    describe PublishEventJob do
      let(:model) { Factory(:social_network) }
      subject do
        PublishEventJob.new(:after_create, model.class.to_s, model.id)
      end

      context ".new" do
        it "should accept a hash" do
          job = PublishEventJob.new(:after_create, 'SocialNetwork', model.serializable_hash)
          job.producer.should_receive(:publish) do |event|
            event.payload.should == model.serializable_hash
          end

          job.perform
        end

        it "should accept entity ID" do
          job = PublishEventJob.new(:after_create, 'SocialNetwork', model.id)
          job.producer.should_receive(:publish) do |event|
            event.payload.should == model
          end

          job.perform
        end
      end

      context "#perform" do
        it "should invoke Untied::Publisher::Producer#publish" do
          subject.producer.should_receive(:publish) do |event|
            event.name.should == :after_create
            event.payload.should == model
          end

          subject.perform
        end
      end
    end
  end
end

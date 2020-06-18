# -*- encoding : utf-8 -*-
require 'spec_helper'

module EnrollmentService
  describe UntiedAdapter do
    subject { UntiedAdapter.new }
    let(:enrollment) { FactoryBot.build(:enrollment) }

    context "#produce_event" do
      it "should enqueue the event" do
        subject.queue.should_receive(:enqueue).with(:after_create, enrollment)
        subject.produce_event(:after_create, enrollment)
      end

      it "should enqueue multiple events" do
        subject.queue.should_receive(:enqueue).
          with(:after_create, an_instance_of(Enrollment)).twice
        subject.produce_event(:after_create, FactoryBot.build_list(:enrollment, 2))
      end
    end

    %w(after_create after_destroy).each do |event|
      it "should invoke #produce_event for #{event}" do
        subject.should_receive(:produce_event).
          with(event.to_sym, an_instance_of(Enrollment))
        subject.send("notify_#{event}", enrollment)
      end
    end
  end
end

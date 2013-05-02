require 'spec_helper'

module EnrollmentService
  describe UntiedAdapter do
    subject { UntiedAdapter.new }
    let(:enrollment) { FactoryGirl.build(:enrollment) }

    context "#produce_event" do
      it "should invoke Untied::Publisher::Producer#publish" do
        subject.producer.should_receive(:publish) do |event|
          event.name.should == :after_create
          event.payload.should == enrollment
        end

        subject.produce_event(:after_create, enrollment)
      end

      it "should accept a collection" do
        subject.producer.should_receive(:publish).twice
        enrollments = FactoryGirl.build_list(:enrollment, 1) << enrollment
        subject.produce_event(:after_create, enrollments)
      end
    end

    %w(after_create after_destroy).each do |event|
      it "should invoke #produce_event for #{event}" do
        subject.should_receive(:produce_event).with(event.to_sym, an_instance_of(Enrollment))
        subject.send("notify_#{event}", enrollment)
      end
    end
  end
end

require 'spec_helper'

describe Notifiable do
  subject { Factory(:notifiable) }

  it { should belong_to(:user) }

  context "counter" do
    it "increments counter by one" do
      subject.increment_counter
      subject.counter.should >= 0
    end

    if "increments counter if its nil" do
      subject.counter = nil
      subject.increment_counter
      subject.counter.should == 1
  end
end

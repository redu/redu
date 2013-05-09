require 'spec_helper'

describe BatchNewsletter do
  let!(:users) { 2.times { Factory(:user) } }
  let(:arel) { User.limit(2) }
  subject do
    BatchNewsletter.
      new(:template => "newsletter/newsletter.html.erb", :users => arel)
  end

  context "#send" do
    it "should call find_each" do
      arel.should_receive(:find_each)
      subject.send
    end
  end

  context "#deliver" do
    it "should yield controll" do
      args = arel.collect { |u| [u.email, {:user => u}] }
      expect { |block|
        subject.deliver(&block)
      }.to yield_successive_args(*args)
    end
  end
end

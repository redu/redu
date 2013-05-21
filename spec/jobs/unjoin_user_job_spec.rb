# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UnjoinUserJob do
  let(:course) { mock_model('Course') }
  let(:user) { mock_model('User') }
  subject do
    UnjoinUserJob.new(:course => course, :user => user)
  end

  it "should invoke Course#unjoin for the user" do
    Course.stub(:find_by_id).and_return(course)
    User.stub(:find_by_id).and_return(user)

    course.should_receive(:unjoin)

    Delayed::Job.enqueue(subject, :queue => :general)
  end
end

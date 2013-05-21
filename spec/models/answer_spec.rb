# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Answer do
  subject { FactoryGirl.create(:answer) }

  it { should belong_to :in_response_to }
  it { should validate_presence_of :text }

  it "assigns type" do
    subject.type.should == subject.class.to_s
  end
end

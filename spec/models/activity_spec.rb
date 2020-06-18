# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Activity do
  subject { FactoryBot.create(:activity) }

  it { should validate_presence_of :text }
  it { should have_many(:answers) }

  context "when responding the activity" do
    let(:user) { FactoryBot.create(:user) }
    it "should respond to respont" do
      subject.should respond_to(:respond)
    end

    it "should update the updated_at attribute" do
      subject.respond({:text => "Opa opa opa!"}, user)
      subject.updated_at.should be_within(1).of(Time.zone.now)
    end

    it "should return the answer" do
      ans = subject.respond({:text => "Everybody dancing now!"}, user)
      ans.should be_a(Answer)
    end

    it "should return an saved answer" do
      ans = subject.respond({:text => "Everybody dancing now!"}, user)
      ans.should_not be_new_record
    end
  end
end

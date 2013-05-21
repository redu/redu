# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Enrollment do

  before do
    subject_owner = FactoryGirl.create(:user)
    @space = FactoryGirl.create(:space)
    @space.course.join subject_owner
    @sub = FactoryGirl.create(:subject, :owner => subject_owner,
                       :space => @space)
  end
  subject { FactoryGirl.create(:enrollment, :subject => @sub) }

  it { should belong_to :user }
  it { should belong_to :subject }
  it { should have_many(:asset_reports).dependent :destroy }

  it "responds to grade" do
    should respond_to :grade
  end

  it "responds to graduated" do
    should respond_to :graduated
  end

  context "callbacks" do
    it "creates all assets reports after create" do
      lectures = (1..3).collect { FactoryGirl.create(:lecture, :subject => @sub) }
      new_user = FactoryGirl.create(:user)
      @sub.space.course.join(new_user)
      expect {
        @sub.enroll(new_user)
      }.to change {
        AssetReport.count
      }.by(@sub.lectures.count)
    end
  end

  it_should_behave_like 'have unique index database'
end

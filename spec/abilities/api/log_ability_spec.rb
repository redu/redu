# -*- encoding : utf-8 -*-
require 'api_spec_helper'
require 'cancan/matchers'

describe "Log ability" do
  let(:user) { FactoryGirl.create(:user) }
  subject { Api::Ability.new(user) }

  context "when owner" do
    let(:log) { FactoryGirl.create(:log, :user => user) }
    it "should be able to read" do
      subject.should be_able_to :read, log
    end

    it "should not be able to manage" do
      subject.should_not be_able_to :manage, log
    end
  end

  context "when statusable is user" do
    let(:strange) { FactoryGirl.create(:user) }
    let(:log) { FactoryGirl.create(:log, :statusable => strange) }

    it "should be able to read if friend" do
      user.be_friends_with(strange)
      strange.be_friends_with(user)

      subject.should be_able_to :read, log
    end

    it "should not be able to read if not friend" do
      subject.should_not be_able_to :read, log
    end
  end

  context "when statusable is course" do
    it_should_behave_like "log on hierarchy" do # spec/support/api/log_on_hiera...
      let(:course) do
        FactoryGirl.create(:complete_environment).courses.first
      end
      let(:log) { FactoryGirl.create(:log, :statusable => course) }
    end
  end

  context "when statusable is space" do
    it_should_behave_like "log on hierarchy" do # spec/support/api/log_on_hiera...
      let(:course) { FactoryGirl.create(:complete_environment).courses.first }
      let(:space) { course.spaces.first }
      let(:log) { FactoryGirl.create(:log, :statusable => space) }
    end
  end

  context "when statusable is lecture" do
    it_should_behave_like "log on hierarchy" do # spec/support/api/log_on_hiera...
      let(:course) { FactoryGirl.create(:complete_environment).courses.first }
      let(:space) { course.spaces.first }
      let(:lecture) do
        s = FactoryGirl.create(:subject, :owner => space.owner, :space => space)
        FactoryGirl.create(:lecture, :owner => s.owner, :subject => s)
      end
      let(:log) { FactoryGirl.create(:log, :statusable => lecture) }
    end
  end
end

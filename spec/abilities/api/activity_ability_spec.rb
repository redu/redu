# -*- encoding : utf-8 -*-
require 'api_spec_helper'
require 'cancan/matchers'

describe "Activity ability" do
  let(:user) { FactoryGirl.create(:user) }
  subject { Api::Ability.new(user) }

  context "when owner" do
    let(:activity) { FactoryGirl.create(:activity, :user => user) }

    it "should be able to manage" do
      subject.should be_able_to :manage, activity
    end
  end

  context "when statusable is an user" do
    let(:strange){ FactoryGirl.create(:user) }
    let(:activity) { FactoryGirl.create(:activity, :statusable => strange) }

    it "should be able to read if friends" do
      user.be_friends_with(strange)
      strange.be_friends_with(user)

      subject.should be_able_to :read, activity
    end

    it "should not be able to read if not friends" do
      subject.should_not be_able_to :read, activity
    end
  end

  context "when statusable is a space" do
    let(:space) do
      FactoryGirl.create(:complete_environment).courses.first.spaces.first
    end
    let(:activity) { FactoryGirl.create(:activity, :statusable => space) }

    it "should be able to read if member" do
      space.course.join(user)
      subject.should be_able_to :read, activity
    end

    it "should not be able to read if not member" do
      subject.should_not be_able_to :read, activity
    end

    it "should be able to manage if environment_admin" do
      space.course.join(user, Role[:environment_admin])
      subject.should be_able_to :manage, activity
    end

    it "should not be able to manage if member" do
      space.course.join(user)
      subject.should_not be_able_to :manage, activity
    end

    it "should be able to manage if teacher" do
      space.course.join(user, Role[:teacher])
      subject.should be_able_to :manage, activity
    end
  end

  context "when statusable is a lecture" do
    it_should_behave_like "activity on lecture" do
      let(:space) do
        FactoryGirl.create(:complete_environment).courses.first.spaces.first
      end
      let(:lecture) do
        s = FactoryGirl.create(:subject, :owner => space.owner, :space => space)
        FactoryGirl.create(:lecture, :owner => s.owner, :subject => s)
      end
      let(:status) do
        FactoryGirl.create(:activity, :user => lecture.owner, :statusable => lecture)
      end
    end
  end
end

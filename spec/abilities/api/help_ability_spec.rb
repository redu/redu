# -*- encoding : utf-8 -*-
require 'api_spec_helper'
require 'cancan/matchers'

describe "Help ability" do
  let(:user) { Factory(:user) }
  subject { Api::Ability.new(user) }

  context "when owner" do
    let(:course) { Factory(:complete_environment).courses.first }
    let(:space) { course.spaces.first }
    let(:lecture) do
      s = Factory(:subject, :owner => space.owner, :space => space)
      Factory(:lecture, :owner => s.owner, :subject => s)
    end
    let(:help) { Factory(:help, :user => user, :statusable => lecture) }

    it "should be able to manage" do
      subject.should be_able_to :manage, help
    end
  end

  context "when statusable is a lecture" do
    it_should_behave_like "activity on lecture" do
      let(:space) do
        Factory(:complete_environment).courses.first.spaces.first
      end
      let(:lecture) do
        s = Factory(:subject, :owner => space.owner, :space => space)
        Factory(:lecture, :owner => s.owner, :subject => s)
      end
      let(:status) do
        Factory(:help, :user => lecture.owner, :statusable => lecture)
      end
    end
  end
end


# -*- encoding : utf-8 -*-
require 'api_spec_helper'
require 'cancan/matchers'

describe "Answer ability" do
  let(:user) { Factory(:user) }
  subject { Api::Ability.new(user) }

  context "when owner" do
    let(:answer) do
      Factory(:answer, :user => user, :in_response_to => Factory(:activity))
    end

    it "should be able to manage" do
      subject.should be_able_to :manage, answer
    end
  end

  context "when in response to a status" do
    it_should_behave_like "activity on lecture" do
      let(:space) do
        Factory(:complete_environment).courses.first.spaces.first
      end
      let(:lecture) do
        s = Factory(:subject, :owner => space.owner, :space => space)
        Factory(:lecture, :owner => s.owner, :subject => s)
      end
      let(:in_response_to) { Factory(:activity, :statusable => lecture) }
      let(:status) do
        Factory(:answer, :user => lecture.owner, :in_response_to => in_response_to)
      end
    end
  end
end


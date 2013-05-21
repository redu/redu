# -*- encoding : utf-8 -*-
require 'api_spec_helper'
require 'cancan/matchers'

describe "Answer ability" do
  let(:user) { FactoryGirl.create(:user) }
  subject { Api::Ability.new(user) }

  context "when owner" do
    let(:answer) do
      FactoryGirl.create(:answer, :user => user, :in_response_to => FactoryGirl.create(:activity))
    end

    it "should be able to manage" do
      subject.should be_able_to :manage, answer
    end
  end

  context "when in response to a status" do
    it_should_behave_like "activity on lecture" do
      let(:space) do
        FactoryGirl.create(:complete_environment).courses.first.spaces.first
      end
      let(:lecture) do
        s = FactoryGirl.create(:subject, :owner => space.owner, :space => space)
        FactoryGirl.create(:lecture, :owner => s.owner, :subject => s)
      end
      let(:in_response_to) { FactoryGirl.create(:activity, :statusable => lecture) }
      let(:status) do
        FactoryGirl.create(:answer, :user => lecture.owner, :in_response_to => in_response_to)
      end
    end
  end
end


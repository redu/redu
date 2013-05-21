# -*- encoding : utf-8 -*-
require 'api_spec_helper'
require 'cancan/matchers'

describe "Myfile ability" do
  let(:user) { FactoryGirl.create(:user) }
  subject { Api::Ability.new(user) }

  let(:environment) { FactoryGirl.create(:complete_environment) }
  let(:course) { environment.courses.first }
  let(:space) { course.spaces.first }
  let(:folder) { FactoryGirl.create(:folder, :space => space) }
  let(:myfile) { FactoryGirl.create(:myfile, :folder => folder) }

  context "when not a member" do
    it "should not be able to manage" do
      subject.should_not be_able_to :manage, myfile
    end

    it "should not be able to read" do
      subject.should_not be_able_to :read, myfile
    end
  end

  context "when member" do
    before do
      course.join user, Role[:member]
    end

    it "should not be able to manage" do
      subject.should_not be_able_to :manage, myfile
    end

    it "should be able to read" do
      subject.should be_able_to :read, myfile
    end
  end

  context "when teacher" do
    before do
      course.join user, Role[:teacher]
    end

    it "should be able to manage" do
      subject.should be_able_to :manage, myfile
    end

    it "should be able to read" do
      subject.should be_able_to :read, myfile
    end
  end

  context "when tutor" do
    before do
      course.join user, Role[:tutor]
    end

    it "should be able to manage" do
      subject.should be_able_to :manage, myfile
    end

    it "should be able to read" do
      subject.should be_able_to :read, myfile
    end
  end

  context "when environment_admin" do
    before do
      course.join user, Role[:environment_admin]
    end

    it "should be able to manage" do
      subject.should be_able_to :manage, myfile
    end

    it "should be able to read" do
      subject.should be_able_to :read, myfile
    end
  end
end

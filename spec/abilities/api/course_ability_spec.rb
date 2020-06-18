# -*- encoding : utf-8 -*-
require 'api_spec_helper'
require 'cancan/matchers'

describe "Course abilities" do
  subject { Api::Ability.new(@user) }
  before do
    @environment = FactoryBot.create(:complete_environment)
    @course = @environment.courses.first
    @user = FactoryBot.create(:user)
  end

  context "when not a member" do
    it "should not be able to read" do
      subject.should_not be_able_to :read, @course
    end
    it "should not be able to create" do
      course = @environment.courses.new do |c|
        c.owner = @user
      end
      subject.should_not be_able_to :create, course
    end
  end

  context "when member" do
    before do
      @course.join(@user)
    end

    it "should not be able to manage" do
      subject.should_not be_able_to :manage, @course
    end

    it "should be able to read" do
      subject.should be_able_to :read, @course
    end
  end

  context "when teacher" do
    before do
      @course.join(@user, Role[:teacher])
    end

    it "should not be able to manage" do
      subject.should_not be_able_to :manage, @course
    end

    it "should be able to read" do
      subject.should be_able_to :read, @course
    end
  end

  context "when tutor" do
    before do
      @course.join(@user, Role[:tutor])
    end

    it "should not be able to manage" do
      subject.should_not be_able_to :manage, @course
    end

    it "should be able to read" do
      subject.should be_able_to :read, @course
    end
  end

  context "when environment admin" do
    before do
      @course.join(@user, Role[:environment_admin])
    end

    it "should be able to manage" do
      subject.should be_able_to :manage, @course
    end
  end
end

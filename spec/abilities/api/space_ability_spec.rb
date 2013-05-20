# -*- encoding : utf-8 -*-
require 'api_spec_helper'
require 'cancan/matchers'

describe "Space abilities" do
  subject { Api::Ability.new(@user) }
  before do
    @environment = Factory(:complete_environment)
    @course = @environment.courses.first
    @space = @course.spaces.first
    @user = Factory(:user)
    @application, @current_user, @token = generate_token(@user)
  end

  context "when environment_admin" do
    before do
      @course.join(@user, Role[:environment_admin])
    end

    it "should be able to create" do
      space = @course.spaces.new
      subject.should be_able_to :create, space
    end
    it "should be able to manage" do
      subject.should be_able_to :manage, @space
    end
  end

  context "when not a member" do
    it "should not be able to read" do
      subject.should_not be_able_to :read, @space
    end
  end

  context "when member" do
    before do
      @course.join(@user, Role[:member])
    end

    it "should not be able to manage" do
      subject.should_not be_able_to :manage, @space
    end
    it "should be able to read" do
      subject.should be_able_to :read, @space
    end
  end

  context "when teacher" do
    before do
      @course.join(@user, Role[:teacher])
    end
    it "should be able to manage" do
      subject.should be_able_to :manage, @space
    end
    it "should be able to create" do
      space = @course.spaces.new
      subject.should be_able_to :create, space
    end
  end

  context "when tutor" do
    before do
      @course.join(@user, Role[:tutor])
    end

    it "should not be able to manage" do
      subject.should_not be_able_to :manage, @space
    end
    it "should be able to read" do
      subject.should be_able_to :read, @space
    end
  end

  context "when unapproved member" do



  end
end

# -*- encoding : utf-8 -*-
require 'api_spec_helper'
require 'cancan/matchers'

describe "Subject(the subject of a space) abilities" do
  subject { Api::Ability.new(@user) }
  before do
    @environment = FactoryGirl.create(:complete_environment)
    @course = @environment.courses.first
    @space = @course.spaces.first
    @user = FactoryGirl.create(:user)
    @subject = Subject.create(:name => "Test Subject 1",
                              :description => "Test Subject Description",
                              :space => @space)
    @application, @current_user, @token = generate_token(@user)
  end

  context "when not a member" do
    it "should not be able to read" do
      subject.should_not be_able_to :read, @subject
    end
  end

  context "when member" do
    before do
      @course.join(@user, Role[:member])
    end

    it "should be able to read" do
      subject.should be_able_to :read, @subject
    end
  end

  context "when teacher" do
    before do
      @course.join(@user, Role[:teacher])
    end

    it "should be able to read" do
      subject.should be_able_to :read, @subject
    end

    it "should be able to destroy" do
      subject.should be_able_to :destroy, @subject
    end
  end

  context "when tutor" do
    before do
      @course.join(@user, Role[:tutor])
    end

    it "should be able to read" do
      subject.should be_able_to :read, @subject
    end

    it "should not be able to destroy" do
      subject.should_not be_able_to :destroy, @subject
    end
  end

  context "when environment_admin" do
    before do
      @course.join(@user, Role[:environment_admin])
    end

    it "should be able to read" do
      subject.should be_able_to :read, @subject
    end

    it "should be able to destroy" do
      subject.should be_able_to :destroy, @subject
    end
  end
end

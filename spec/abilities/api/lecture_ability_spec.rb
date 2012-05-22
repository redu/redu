require 'api_spec_helper'
require 'cancan/matchers'

describe "Lecture abilities" do
  subject { Api::Ability.new(@user) }
  before do
    @course = Factory(:course)
    @space = Factory(:space, :course => @course)
    @user = Factory(:user)
    @subject = Factory(:subject, :space => @space)
    @subject.update_attribute(:finalized, true)
    @lecture = Factory(:lecture, :subject => @subject)

    @application, @current_user, @token = generate_token(@user)
  end

  context "when not a member" do
    it "should not be able to read" do
      subject.should_not be_able_to :read, @lecture
    end
  end

  context "when member" do
    before do
      @course.join(@user, Role[:member])
    end

    it "should be able to read" do
      subject.should be_able_to :read, @lecture
    end

    it "should not be able to create a lecture" do
      subject.should_not be_able_to :create, @lecture
    end
  end

  context "when teacher" do
    before do
      @course.join(@user, Role[:teacher])
    end

    it "should be able to read" do
      subject.should be_able_to :read, @lecture
    end

    it "should be able to create" do
      subject.should be_able_to :create, @lecture
    end

    it "should be able to destroy" do
      subject.should be_able_to :destroy, @lecture
    end
  end

  context "when tutor" do
    before do
      @course.join(@user, Role[:tutor])
    end

    it "should be able to read" do
      subject.should be_able_to :read, @lecture
    end

    it "should not be able to create a lecture" do
      subject.should_not be_able_to :create, @lecture
    end

    it "should not be able to destroy" do
      subject.should_not be_able_to :destroy, @lecture
    end
  end

  context "when environment_admin" do
    before do
      @course.join(@user, Role[:environment_admin])
    end

    it "should be able to read" do
      subject.should be_able_to :read, @lecture
    end

    it "should be able to create" do
      subject.should be_able_to :create, @lecture
    end

    it "should be able to destroy" do
      subject.should be_able_to :destroy, @lecture
    end
  end
end

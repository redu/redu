require 'api_spec_helper'
require 'cancan/matchers'

describe "Lecture abilities" do
  subject { Api::Ability.new(user) }
  before do
    environment = Factory(:complete_environment)
    @course = environment.courses.first
    space = @course.spaces.first
    @sub = Factory(:subject, :owner => @course.owner,
                       :space => space, :finalized => true)
    @application, @current_user, @token = generate_token(user)
  end

  let(:lecture) { Factory(:lecture, :subject => @sub, :owner => @course.owner) }
  let(:user) { Factory(:user) }

  context "when not a member" do
    it "should not be able to manage" do
      subject.should_not be_able_to :manage, lecture
    end
  end

  context "when member" do
    before do
      @course.join(user, Role[:member])
    end

    it "should not be able to manage" do
      subject.should_not be_able_to :manage, lecture
    end

    it "should be able to read" do
      subject.should be_able_to :read, lecture
    end
  end

  context "when teacher" do
    before do
      @course.join(user, Role[:teacher])
    end

    it "should be able to manage" do
      subject.should be_able_to :manage, lecture
    end

    it "should be able to read" do
      subject.should be_able_to :read, lecture
    end
  end

  context "when tutor" do
    before do
      @course.join(user, Role[:tutor])
    end

    it "should not be able to manage" do
      subject.should_not be_able_to :manage, lecture
    end

    it "should be able to read" do
      subject.should be_able_to :read, lecture
    end
  end

  context "when environment_admin" do
    before do
      @course.join(user, Role[:environment_admin])
    end

    it "should be able to destroy" do
      subject.should be_able_to :manage, lecture
    end

    it "should be able to read" do
      subject.should be_able_to :read, lecture
    end
  end
end

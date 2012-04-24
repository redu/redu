require 'api_spec_helper'
require 'cancan/matchers'

describe "Lecture abilities" do
  subject { Api::Ability.new(@user) }
  before do
    @user = Factory(:user)
  end

  context "when need read lecture" do

    it "should not be able to read" do
      @lecture = Factory(:lecture)
      subject.should_not be_able_to :read, @lecture
    end

    it "should be able to read" do
      @env = Factory(:complete_environment, :owner => @user)
      @course = @env.courses.first
      @space = @course.spaces.first
      @subject = Factory(:subject, :owner => @user, :space => @space)
      @lecture = Factory(:lecture, :subject => @subject, :owner => @user)

      subject.should be_able_to :read, @lecture
    end
  end

end

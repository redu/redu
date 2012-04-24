require 'api_spec_helper'
require 'cancan/matchers'

describe "Subject abilities" do
  subject { Api::Ability.new(@user) }
  before do
    @user = Factory(:user)
  end

  context "when need read subject" do

    it "should not be able to read" do
      @subject = Factory(:subject)
      subject.should_not be_able_to :read, @subject
    end

    it "should be able to read" do
      @env = Factory(:complete_environment, :owner => @user)
      @course = @env.courses.first
      @space = @course.spaces.first
      @subject = Factory(:subject, :owner => @user, :space => @space)

      subject.should be_able_to :read, @subject
    end
  end

end

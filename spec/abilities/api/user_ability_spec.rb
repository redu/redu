require "api_spec_helper"
require 'cancan/matchers'

describe Api::Ability do
  context "when user" do
    subject { Api::Ability.new(@user) }
    before do
      @user = Factory(:user)
    end

    it "should be able to manage itself" do
      subject.should be_able_to :manage, @user
    end
  end

  context "when guest" do
    subject { Api::Ability.new(nil) }
    it "shold not be able read" do
      subject.should_not be_able_to :read, User
    end
  end
end

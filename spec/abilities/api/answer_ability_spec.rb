require 'api_spec_helper'
require 'cancan/matchers'

describe "Answer abilities" do
  subject { Api::Ability.new(@user) }
  before do
    @user = Factory(:user)
  end


  context "when in response to activity" do
    before do
      @answer = Factory(:answer)
    end

    it "should not be able to read" do
      subject.should_not be_able_to :read, @answer
    end

    it "should be able to read" do
      @answer.user = @user
      @answer.in_response_to.user = @user
      subject.should be_able_to :read, @answer
    end

    it "should not be able to create" do
      @answer = Answer.new(:text => "Ximbica answer in response to activity")
      @answer.user = Factory(:user)
      subject.should_not be_able_to :create, @answer
    end

    it "should be able to create" do
      @answer = Answer.new(:text => "Ximbica answer in response to activity")
      @answer.user = Factory(:user)
      @answer.in_response_to = Factory(:activity)
      @answer.in_response_to.user = @user
      subject.should be_able_to :create, @answer
    end

    it "should not be able to destroy" do
      subject.should_not be_able_to :destroy, @answer
    end

    it "should be able to destroy" do
      @answer.user = @user
      subject.should be_able_to :destroy, @answer
    end
  end

  context "when in response to help" do
    before do
      @answer = Factory(:answer, :in_response_to => Factory(:help))
    end

    it "should not be able to read" do
      subject.should_not be_able_to :read, @answer
    end

    it "should be able to read" do
      @answer.user = @user
      @answer.in_response_to.user = @user
      subject.should be_able_to :read, @answer
    end

    it "should not be able to create" do
      @answer = Answer.new(:text => "Ximbica answer in response to help")
      @answer.user = Factory(:user)
      subject.should_not be_able_to :create, @answer
    end

    it "should be able to create" do
      @answer = Answer.new(:text => "Ximbica answer in response to help")
      @answer.user = Factory(:user)
      @answer.in_response_to = Factory(:help)
      @answer.in_response_to.user = @user
      subject.should be_able_to :create, @answer
    end

    it "should not be able to destroy" do
      subject.should_not be_able_to :destroy, @answer
    end

    it "should be able to destroy" do
      @answer.user = @user
      subject.should be_able_to :destroy, @answer
    end
  end
end

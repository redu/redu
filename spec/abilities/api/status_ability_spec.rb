require 'api_spec_helper'
require 'cancan/matchers'

describe "Statuses abilities" do
  subject { Api::Ability.new(@user) }
  before do
    @user = Factory(:user)
  end

  context "when Activity type" do
    before do
      @activity = Factory(:activity)
    end

    it "should not be able to read" do
      subject.should_not be_able_to :read, @activity
    end

    it "should be able to read" do
      @activity.user = @user
      subject.should be_able_to :read, @activity
    end

    it "should not be able to create" do
      @status = Activity.new(:text => "Ximbica Activity")
      @status.user = Factory(:user)
      @status.statusable = @status.user
      subject.should_not be_able_to :create, @status
    end

    it "should be able to create" do
      @status = Activity.new(:text => "Ximbica Activity")
      @status.user = @user
      @status.statusable = @user
      subject.should be_able_to :create, @status
    end

    it "should not able to destroy" do
      subject.should_not be_able_to :destroy, @activity
    end

    it "should able to destroy" do
      @activity.user = @user
      subject.should be_able_to :destroy, @activity
    end
  end

  context "when Log type" do
    before do
      @log = Factory(:log)
    end

    it "should not be able to read" do
      subject.should_not be_able_to :read, @log
    end

    it "should be able to read" do
      @log.user = @user
      subject.should be_able_to :read, @log
    end

    it "should not be able to create" do
      @log.user = @user
      subject.should_not be_able_to :create, @log
    end

    it "should not be able to destroy" do
      @log.user = @user
      subject.should_not be_able_to :destroy, @log
    end
  end

  context "when Help type" do
    before do
      @help = Factory(:help)
    end

    it "should not be able to read" do
      subject.should_not be_able_to :read, @help
    end

    it "should be able to read" do
      @help.user = @user
      subject.should be_able_to :read, @help
    end

    it "should not be able to create" do
      subject.should_not be_able_to :create, @help
    end

    it "should be able to create" do
      @help.user = @user
      subject.should be_able_to :create, @help
    end

    it "should not be able to destroy" do
      subject.should_not be_able_to :destroy, @help
    end

    it "should be able to destroy" do
      @help.user = @user
      subject.should be_able_to :destroy, @help
    end
  end

  end
end

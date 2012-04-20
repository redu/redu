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
      @status.user = @user
      @status.statusable = @user
      subject.should_not be_able_to :create, @activity
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

end

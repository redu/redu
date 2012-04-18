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
  end
end

require 'spec_helper'

describe LoggingObserver do
  context "user" do
    before do
      @user = Factory(:user)
    end

    it "creates a creation log" do
      @user.logs.count(:action => "create").should == 1
    end
  end
end

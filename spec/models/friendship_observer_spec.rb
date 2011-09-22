require 'spec_helper'

describe FriendshipObserver do
  context "logger" do
    it "logs firendship" do
      ActiveRecord::Observer.with_observers(:friendship_observer) do
        @user1 = Factory(:user)
        @user2 = Factory(:user)

        expect {
          @user1.be_friends_with(@user2)
          @user2.be_friends_with(@user1)
        }.should change(Log, :count).by(2)
      end
    end
  end
end

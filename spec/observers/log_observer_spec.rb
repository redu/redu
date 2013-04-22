require 'spec_helper'

describe LogObserver do
  context "after create" do
    before do
      user = Factory(:user)
      friend = Factory(:user)
      user.be_friends_with(friend)
      friend.be_friends_with(user)

      @friendship = user.friendships.first
      @uca = Factory(:user_course_association, :state => "approved")
    end

   it "should be performed uca compounds" do
     ActiveRecord::Observer.with_observers(:log_observer) do
       expect {
         Factory(:log, :logeable => @uca)
       }.to change(CompoundLog, :count).by(1)
     end
   end

   it "should be performed friendship compounds" do
     ActiveRecord::Observer.with_observers(:log_observer) do
       expect {
         Factory(:log, :logeable => @friendship)
       }.to change(CompoundLog, :count).by(1)
     end
   end
  end
end

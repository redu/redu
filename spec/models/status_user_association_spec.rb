require 'spec_helper'

describe StatusUserAssociation do
  it { should belong_to(:user) }
  it { should belong_to(:status) }

  xit { should validate_uniqueness_of(:status_id) }

  context "when multiple SUA with the same observer" do
    before do
      @user1 = Factory(:user)
      @user2 = Factory(:user)
      @user1.be_friends_with(@user2)
      @user2.be_friends_with(@user1)

      @contacts = 2.times.inject([]) do |acc,u|
        user = Factory(:user)
        user.be_friends_with(@user1)
        @user1.be_friends_with(user)
        @user2.be_friends_with(user)
        user.be_friends_with(@user2)
        acc << user
      end

      @user3 = Factory(:user)
      @user3.be_friends_with(@user2)
      @user2.be_friends_with(@user3)

      ActiveRecord::Observer.with_observers(:status_observer) do
        @activity = Factory(:activity, :user => @user1, :statusable => @user2)
      end
    end

    it "cannot duplicate SOA" do
      StatusUserAssociation.count.should == 5
    end

    it "creates overview association" do
      statuses = @contacts.collect { |u| u.overview }.flatten.uniq
      statuses.size.should == 1
      statuses.first.should == @activity
    end
  end
end

require 'spec_helper'

describe Invitation do

  subject {
    user = Factory(:user)
    Invitation.new(:user => user, :hostable => user, :email => 'email@example.com', :token => 't0k3N')
  }
  xit { should validate_uniqueness_of :token }

  context ':Callbacks:' do
    it 'Token should be gerenated before create invitation' do
      subject.token = nil
      subject.valid?.should be_true
      subject.token.should_not be_nil
    end
  end

  context ':Associations:' do
    it 'Invitations should have a sender' do
      should belong_to :user
    end

    it 'A Invitation have only one host' do
      should_not have_many :users
    end

    it 'Users can send one or more invitations' do
      user = Factory(:user)
      user.should have_many :invitations
    end

    it 'When a user is deleted, all his invitations should be deleted' do
      user = Factory(:user)
      invitation = FactoryGirl.build(:invitation, :user => user, :hostable => user, :email => subject.email)
      invitation.save.should be_true
      expect {Invitation.find(invitation.id)}.should_not raise_error
      user.destroy.should_not be_nil
      lambda {Invitation.find(invitation.id)}.should raise_error
    end
  end

  context ':Friends invitations:' do
    it "User can't invite itself" do
      subject.email = subject.user.email
      subject.save.should be_false
      subject.accept!(subject.user).should be_false
    end

    it "User can invite many other users" do
      subject.save.should be_true
      subject.accept!(Factory(:user)).should be_true
    end

    it "Invites to same email should not be valid when sended by same user" do
      invitation = FactoryGirl.build(:invitation, :user => subject.user, :hostable => subject.hostable, :email => subject.email)
      invitation.save.should be_true
      subject.save.should be_false
      subject.errors[:email].should_not be_empty
    end

    it "Invalid email on invite should make a invalid invitation" do
      subject.email = 'invalid.com'
      subject.should_not be_valid
      subject.errors[:email].should_not be_empty
    end

    it "Invitations whitout email should be invalid" do
      subject.email = nil
      subject.should_not be_valid
      subject.errors[:email].should_not be_empty
    end

    it "Create and send email invitation with static method" do
      invitation = Invitation.invite(:user => subject.user, :hostable => subject.hostable, :email => subject.email) do |invitation|
        UserNotifier.friendship_invitation(invitation).deliver
      end
      invitation.should be_valid
    end

    it "User can delete invitations" do
      user = Factory(:user)
      invitation = FactoryGirl.build(:invitation, :user => user, :hostable => user, :email => subject.email)
      invitation.save.should be_true
      invitation.destroy.should_not be_nil
      user.invitations.include?(invitation).should be_false
    end
  end

  context ':Send email:' do
    before do
      UserNotifier.delivery_method :test
      UserNotifier.perform_deliveries = true
      UserNotifier.deliveries = []
    end

   it 'Users can resend invitation email' do
     ActiveRecord::Observer.with_observers(:friendship_observer) do
       subject.save.should be_true
       subject.resend_email do |invitation|
         UserNotifier.friendship_invitation(invitation).deliver
         UserNotifier.deliveries.should_not be_empty
      end
     end
    end
  end
end

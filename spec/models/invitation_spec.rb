require 'spec_helper'

describe Invitation do

  xit { should validate_uniqueness_of :token }

  context 'Callbacks' do
    it 'Token should be gerenated before create invitation' do
      invitation = FactoryGirl.build(:invitation, :token => nil)
      invitation.hostable = Factory(:user)
      invitation.valid? # Chamando valid (callback token)
      invitation.token.should_not be_nil
    end
  end

  context 'Associations' do
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
  end

  context 'Friends invitations' do

    #FIXME: validar email
    it "User can't invite itself" do
      user = Factory(:user)
      invitation = FactoryGirl.build(:invitation)
      invitation.hostable = user
      invitation.email = user.email
      invitation.accept!(user).should be_false
    end

    #FIXME: validar email
    it "User can invite many other users" do
      user = Factory(:user)
      invitation = FactoryGirl.build(:invitation)
      invitation.hostable = user
      invitation.accept!(Factory(:user)).should be_true
    end

    it "Invites to same email should not be valid" do
      user = Factory(:user)
      i1= FactoryGirl.build(:invitation)
      i2 = FactoryGirl.build(:invite)
      i1.hostable = user
      i2.hostable = user
      i1.save
      i2.save.should be_false

    end
  end
end

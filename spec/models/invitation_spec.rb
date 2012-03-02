require 'spec_helper'

describe Invitation do

  context 'Associations' do
    it 'Invitations should have a sender' do
      should belong_to :user
    end

    it 'Users can send one or more invitations' do
      user = Factory(:user)
      user.should have_many :invitations
    end
  end
end

# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UserSpaceAssociation do
  subject { FactoryBot.create(:user_space_association) }

  it { should belong_to :user }
  it { should belong_to :space }

  # FIXME Problema de tradução
  xit { should validate_uniqueness_of(:user_id).scoped_to :space_id }

  context "finders" do
    it "retrieves user space association with specified keyword" do
      user = FactoryBot.create(:user, :first_name => "Andrew")
      assoc = FactoryBot.create(:user_space_association, :user => user)
      user2 = FactoryBot.create(:user, :first_name => "Joe Andrew")
      assoc2 = FactoryBot.create(:user_space_association, :user => user2)
      user3 = FactoryBot.create(:user, :first_name => "Alice")
      assoc3 = FactoryBot.create(:user_space_association, :user => user3)

      UserSpaceAssociation.users_by_name("Andrew").
        should == [user.user_space_associations.last,
          user2.user_space_associations.last]
    end
  end
end

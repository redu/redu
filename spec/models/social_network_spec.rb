# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SocialNetwork do
  subject { FactoryBot.create(:social_network) }

  it { should belong_to :user }

end

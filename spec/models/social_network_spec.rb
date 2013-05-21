# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SocialNetwork do
  subject { FactoryGirl.create(:social_network) }

  it { should belong_to :user }

end

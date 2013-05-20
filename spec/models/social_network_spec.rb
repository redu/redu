# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SocialNetwork do
  subject { Factory(:social_network) }

  it { should belong_to :user }

end

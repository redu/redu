# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Page do
  subject { FactoryGirl.create(:page) }

  it { should have_one :lecture }
  it { should validate_presence_of :body }
end

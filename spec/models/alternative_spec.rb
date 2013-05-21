# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Alternative do
  it { should have_many(:choices).dependent(:destroy) }
  it { should validate_presence_of(:text) }
end

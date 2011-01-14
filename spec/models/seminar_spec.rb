require 'spec_helper'

describe Seminar do
  subject { Factory(:seminar) }

  it { should have_one :lecture }

  it "validates youtube URL"
  it "truncates youtube URL"

end

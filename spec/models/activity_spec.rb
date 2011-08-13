require 'spec_helper'

describe Activity do
  subject { Factory(:activity) }

  it { should validate_presence_of :text }
  it { should have_many(:answers) }
end

require 'spec_helper'

describe Alternative do
  it { should have_many(:choices).dependent(:destroy) }
end

require 'spec_helper'

describe ClientApplication do
  it { should have_many(:tokens).dependent(:destroy) }
  it { should have_many(:access_tokens).dependent(:destroy) }
  it { should have_many(:oauth2_verifiers).dependent(:destroy) }
  it { should have_many(:oauth_tokens).dependent(:destroy) }
end

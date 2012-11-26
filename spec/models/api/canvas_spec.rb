require 'spec_helper'

describe Api::Canvas do
  it { should belong_to :user }
  it { should belong_to :client_application }
  it { should have_one :lecture }
  it { should validate_presence_of :client_application }
end

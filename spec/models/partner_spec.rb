require 'spec_helper'

describe Partner do
  subject { Factory(:partner) }

  it { should respond_to :name }
  it { should validate_presence_of :name }
  it { should have_many(:environments).through(:partner_environment_associations) }
end

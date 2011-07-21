require 'spec_helper'

describe PartnerEnvironmentAssociation do
  subject { Factory(:partner_environment_association) }

  it { should belong_to :partner }
  it { should belong_to :environment }
  it { should validate_presence_of :cnpj }
  it { should accept_nested_attributes_for :environment }
end

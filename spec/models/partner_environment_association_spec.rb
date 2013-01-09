require 'spec_helper'

describe PartnerEnvironmentAssociation do
  subject { Factory(:partner_environment_association) }

  it { should belong_to :partner }
  it { should belong_to(:environment).dependent(:destroy) }
  it { should validate_presence_of :cnpj }
  it { should validate_presence_of :address }
  it { should validate_presence_of :company_name }
  it { should accept_nested_attributes_for :environment }

  it "should return formated CNPJ" do
    subject.cnpj = "12123123123412"
    subject.formatted_cnpj.should == "12.123.123/1234-12"
  end

  context "when destroyed billable" do
    before do
      @plan = Factory(:active_package_plan, :billable => subject.environment)
      subject.environment.audit_billable_and_destroy
    end

    it "should return the plan" do
      subject.reload
      subject.environment.should be_nil
      subject.plan_of_dead_environment.should == @plan
    end
  end
end

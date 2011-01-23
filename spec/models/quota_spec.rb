require 'spec_helper'

describe Quota do
  it { should belong_to(:billable) }

  context "when updating quotas" do
  
    it "responds to update_for" do
      should respond_to(:refresh)
    end

    #FIXME Depende da criação de subect
    it "updates quotas successfully"
  
  end
end

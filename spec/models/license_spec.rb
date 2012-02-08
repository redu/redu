require 'spec_helper'

describe License do
  it { should belong_to :invoice }
  it { should validate_presence_of :name }
  it { should validate_presence_of :email }
  it { should validate_presence_of :period_start }
  it { should validate_presence_of :role }

  it { should allow_value('a@b.com').for(:email) }

  context "retrievers" do
    it "retrieves in use licenses" do
      @in_use = (1..10).collect { Factory(:license, :period_end => nil) }
      (1..10).collect { Factory(:license, :period_end => Date.yesterday) }

      License.in_use.to_set.should == @in_use.to_set
    end
  end
end

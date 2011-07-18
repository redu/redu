require 'spec_helper'

describe Education do
  subject { Factory(:education) }

  it { should belong_to :user }
  it { should belong_to(:educationable).dependent(:destroy)}

  it { should validate_presence_of :user }
  it { should validate_presence_of :educationable }

  it { should_not allow_mass_assignment_of :user }

  context "validations" do
    it "validates associated educationable" do
      educ = Factory.build(:education,
                           :educationable => Factory.build(:high_school,
                                                           :institution => ""))
      educ.should_not be_valid
      educ.errors[:educationable].should_not be_empty
    end
  end
end

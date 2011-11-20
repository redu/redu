require 'spec_helper'

describe Alternative do
  it { should have_many(:choices).dependent(:destroy) }
  it { should validate_presence_of(:text) }

  context "validates uniqueness of correct" do
    it "should not be valid when there are two corrects" do
      Factory(:alternative, :correct => true)
      alternative = Factory.build(:alternative, :correct => true)
      alternative.should_not be_valid
    end

    it "should be valid when there arent corrects" do
      Factory(:alternative, :correct => false)
      Factory(:alternative, :correct => false)
      alternative = Factory.build(:alternative, :correct => true)
      alternative.should be_valid
    end
  end
end

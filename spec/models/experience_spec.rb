require 'spec_helper'

describe Experience do
  subject { Factory(:experience) }

  it { should belong_to :user}

  it { should validate_presence_of :title }
  it { should validate_presence_of :company }
  it { should validate_presence_of :start_date }

  it { should_not allow_mass_assignment_of :user}

  context "validations" do
    it "validates presence of end_date if it is not a current experience" do
      @experience = Factory.build(:experience, :current => false,
                                  :end_date => nil)
      @experience.should_not be_valid
      @experience.errors[:end_date].should_not be_nil
    end

    it "validates absense of end_date if it is a current experience" do
      @experience = Factory.build(:experience, :current => true,
                                  :end_date => Date.today + 2.months)
      @experience.should_not be_valid
      @experience.errors[:end_date].should_not be_nil
    end

    it "validates if start_date is before end_date" do
      @experience = Factory.build(:experience, :current => false,
                                  :start_date => Date.today + 1.day,
                                  :end_date => Date.today)
      @experience.should_not be_valid
      @experience.errors[:start_date]
    end
  end
end

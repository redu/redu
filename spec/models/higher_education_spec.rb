require 'spec_helper'

describe HigherEducation do
  subject { Factory(:higher_education) }

  it { should validate_presence_of :kind }
  it { should validate_presence_of :institution }
  it { should validate_presence_of :start_year }
  it { should validate_presence_of :end_year }

  it { should have_one(:education) }

  context "validations" do
    %w(technical degree bachelorship).each do |kind|
      it "validates presence of course when kind is #{kind}" do
        higher = Factory.build(:higher_education, :kind => kind, :course => "")
        higher.should_not be_valid
        higher.errors[:course].should_not be_empty
      end
    end

    %w(pos_stricto_sensu pos_lato_sensu doctorate phd).each do |kind|
      it "validates presence of research_area when kind is #{kind}" do
        higher = Factory.build(:higher_education, :kind => kind,
                               :research_area => "")
        higher.should_not be_valid
        higher.errors[:research_area].should_not be_empty
      end
    end

    %w(technical degree bachelorship).each do |kind|
      it "validates if the kind is one of the permitted ones (#{kind})" do
        higher = Factory.build(:higher_education, :kind => kind,
                               :course => "Course")
        higher.should be_valid
      end
    end

    %w(pos_stricto_sensu pos_lato_sensu doctorate phd).each do |kind|
      it "validates if the kind is one of the permitted ones (#{kind})" do
        higher = Factory.build(:higher_education, :kind => kind,
                               :research_area => "Area", :course => "")
        higher.should be_valid
      end
    end

    it "validates if the kind is not one of the permitted ones" do
        higher = Factory.build(:higher_education, :kind => "not_allowed")
        higher.should_not be_valid
    end
  end

  context "responds" do
    [:technical?, :degree?, :bachelorship?, :pos_stricto_sensu?,
      :pos_lato_sensu?, :doctorate?, :phd?].each do |kind|
        it "responds to #{kind}" do
          should respond_to kind
        end
      end
  end

   context "kinds" do
     it "returns if it is of kind technical" do
      higher = Factory(:higher_education, :kind => "technical")
      higher.should be_technical
     end

     it "returns if it is of kind dregree" do
      higher = Factory(:higher_education, :kind => "degree")
      higher.should be_degree
     end

     it "returns if it is of kind bachelorship" do
      higher = Factory(:higher_education, :kind => "bachelorship")
      higher.should be_bachelorship
     end

     it "returns if it is of kind pos_stricto_sensu" do
      higher = Factory(:higher_education, :kind => "pos_stricto_sensu",
                       :course => "", :research_area => "research")
      higher.should be_pos_stricto_sensu
     end

     it "returns if it is of kind pos_lato_sensu" do
      higher = Factory(:higher_education, :kind => "pos_lato_sensu",
                       :course => "", :research_area => "research")
      higher.should be_pos_lato_sensu
     end

     it "returns if it is of kind doctorate" do
      higher = Factory(:higher_education, :kind => "doctorate",
                       :course => "", :research_area => "research")
      higher.should be_doctorate
     end

     it "returns if it is of kind phd" do
      higher = Factory(:higher_education, :kind => "phd",
                       :course => "", :research_area => "research")
      higher.should be_phd
     end
   end
end

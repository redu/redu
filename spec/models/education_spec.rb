# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Education do
  subject { FactoryBot.create(:education) }

  it { should belong_to :user }
  it { should belong_to(:educationable).dependent(:destroy)}
  it { should have_many :logs }

  it { should validate_presence_of :user }
  it { should validate_presence_of :educationable }

  it { should_not allow_mass_assignment_of :user }

  context "validations" do
    it "validates associated educationable" do
      educ = FactoryBot.build(:education,
                           :educationable => FactoryBot.build(:high_school,
                                                           :institution => ""))
      educ.should_not be_valid
      educ.errors[:educationable].should_not be_empty
    end
  end

  context "finders" do
    before do
      @user = FactoryBot.create(:user)
      @high_school1 = FactoryBot.create(:education,
                              :educationable => FactoryBot.create(:high_school),
                              :user => @user)
      @high_school2 = FactoryBot.create(:education,
                              :educationable => FactoryBot.create(:high_school),
                              :user => @user)
      @higher1 = FactoryBot.create(:education,
                         :educationable => FactoryBot.create(:higher_education),
                         :user => @user)
      @higher2 = FactoryBot.create(:education,
                         :educationable => FactoryBot.create(:higher_education),
                         :user => @user)
      @comp_courses1 = FactoryBot.create(:education,
                               :educationable => FactoryBot.create(:complementary_course),
                               :user => @user)
      @comp_courses2 = FactoryBot.create(:education,
                               :educationable => FactoryBot.create(:complementary_course),
                               :user => @user)
      @event_edu1 = FactoryBot.create(:education,
                            :educationable => FactoryBot.create(:event_education),
                            :user => @user)
      @event_edu2 = FactoryBot.create(:education,
                            :educationable => FactoryBot.create(:event_education),
                            :user => @user)
    end

    it "should retrieve educations that are high schools" do
      @user.educations.high_schools.should == [@high_school1, @high_school2]
    end

    it "should retrieve educations that are higher education" do
      @user.educations.higher_educations.should == [@higher1, @higher2]
    end

    it "should retrieve educations that are complementary courses" do
      @user.educations.complementary_courses.should == [@comp_courses1, @comp_courses2]
    end

    it "should retrieve educations that are event educations" do
      @user.educations.event_educations.should == [@event_edu1, @event_edu2]
    end
  end

end

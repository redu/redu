# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Choice do
  subject { FactoryGirl.create(:choice) }

  it { should belong_to(:alternative) }
  it { should belong_to(:user) }
  it { should belong_to(:question) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:question_id) }

  it_should_behave_like 'have unique index database'

  context "scopes" do

    it "should return all correct choices" do
      correct_choices = FactoryGirl.create_list(:choice, 2, correct: true)
      FactoryGirl.create_list(:choice, 2, correct: false)
      Choice.correct.to_set.should == correct_choices.to_set
    end
  end
end

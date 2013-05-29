# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Choice do
  subject do
    FactoryGirl.create(:choice,
                       :question => FactoryGirl.create(:question))
  end

  it { should belong_to(:alternative) }
  it { should belong_to(:user) }
  it { should belong_to(:question) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:question_id) }

  it_should_behave_like 'have unique index database'

  context "scopes" do
    let(:exercise) { FactoryGirl.create(:exercise) }
    let(:question) { subject.question }

    it "should return all correct choices" do
      correct_choices = FactoryGirl.create_list(:choice, 2, correct: true)
      FactoryGirl.create_list(:choice, 2, correct: false)
      Choice.correct.should =~ correct_choices
    end

    it "should return all choices of an exercise" do
      question2 = FactoryGirl.create(:question, exercise: exercise)
      result = FactoryGirl.create_list(:choice, 2, question: question2)

      Choice.by_exercise(exercise).to_set.should == result.to_set
    end
  end
end

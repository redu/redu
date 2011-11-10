require 'spec_helper'

describe Question do
  subject { Factory(:question) }

  it { should have_many(:alternatives).dependent(:destroy) }
  it { should belong_to(:exercise) }
  it { should have_one(:correct_alternative) }
  it { should validate_presence_of(:statement) }
  it { should have_many(:choices).dependent(:destroy) }
  it { should accept_nested_attributes_for(:alternatives) }

  context "sortable" do
    before do
      subject.exercise = Factory(:exercise)
    end

    it "should respond to next_item" do
      [:next_item, :previous_item, :position].each do |method|
        subject.should respond_to(method)
      end
    end
  end

  context "when responding" do
    before do
      @alternatives = 3.times.collect {
        Factory(:alternative, :question => subject, :correct => false)
      }
      @alternatives.first.update_attribute(:correct, true)
      @user = Factory(:user)
    end

    it "should respond to choose_alternative" do
      subject.should respond_to(:choose_alternative)
    end

    it "should choose alternative" do
      expect {
        subject.choose_alternative(@alternatives.first, @user)
      }.should change(Choice, :count).by(1)
    end

    it "should choose alternative when passing an ID" do
      alt_id = @alternatives.first.id

      expect {
        subject.choose_alternative(alt_id, @user)
      }.should change(Choice, :count).by(1)
    end

    it "should assign the user" do
      choice = subject.choose_alternative(@alternatives.first, @user)
      choice.user.should == @user
    end

    it "should assign correctness when correct choice" do
      choice = subject.choose_alternative(@alternatives.first, @user)
      choice.correct.should be_true
    end

    it "should assign correctness when wrong choice" do
      choice = subject.choose_alternative(@alternatives.last, @user)
      choice.correct.should be_false
    end
  end

  context "when responding again" do
    before do
      @alternatives = 3.times.collect {
        Factory(:alternative, :question => subject, :correct => false)
      }
      @alternatives.first.update_attribute(:correct, true)
      @user = Factory(:user)
    end

    it "should not create another choice" do
      subject.choose_alternative(@alternatives.last, @user)
      expect {
        subject.choose_alternative(@alternatives.first, @user)
      }.should_not change(Choice, :count)
    end

    it "should update the choice" do
      choice = subject.choose_alternative(@alternatives.first, @user)
      new_choice = subject.choose_alternative(@alternatives.last, @user)

      new_choice.should == choice
      new_choice.correct.should be_false
    end
  end
end

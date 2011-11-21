require 'spec_helper'

describe Exercise do
  subject { Factory(:exercise) }

  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:results).dependent(:destroy) }
  it { should have_many(:explained_questions) }
  it { should have_one(:lecture) }
  it { should accept_nested_attributes_for(:questions) }

  it { should accept_nested_attributes_for(:questions) }

  it "should not make sense when there arent questions" do
    subject.make_sense?.should_not be_true
    subject.errors.get(:general).should_not be_empty
  end

  it "should make sense when there are questions" do
    exercise = Factory(:complete_exercise)
    exercise.make_sense?.should be_true
  end

  it "should not make sense when there are questions marked for destruction" do
    exercise = Factory(:complete_exercise)
    questions = exercise.questions
    mass = { :questions_attributes =>
             [{:id => questions[0].id, :_destroy => true},
              {:id => questions[1].id, :_destroy => true},
              {:id => questions[2].id, :_destroy => true}] }

    exercise.attributes = mass
    exercise.make_sense?.should_not be_true
  end

  it "should not make sense when there are alternatives makerd for destruction" do
    exercise = Factory(:complete_exercise)
    question = exercise.questions.last
    alt1, alt2 = question.alternatives[0], question.alternatives[1]
    mass = { :alternatives_attributes => [
      { :id => alt1.id, :_destroy => true },
      { :id => alt2.id, :_destroy => true }] }

    exercise.attributes = { :questions_attributes => [ {:id => question.id}.merge!(mass) ]}
    exercise.make_sense?.should_not be_true
  end

  it "should not make sense when one question has just one alternative" do
    question = Factory(:complete_question, :exercise => subject)
    question.alternatives[0].destroy
    question.alternatives[1].destroy
    subject.make_sense?.should_not be_true
  end

  it "should respond to question weight" do
    subject.should respond_to(:question_weight)
  end

  it "shoult respond to maximum weight" do
    subject.should respond_to(:maximum_grade)
  end

  context "when there arent questions" do
    it "should calculate the question weight" do
      subject.question_weight.should == BigDecimal.new("0")
    end
  end

  context "when there are questions" do
    before do
      @questions = 3.times.inject([]) { |acc, i|
        acc << Factory(:question, :exercise => subject)
      }
    end

    it "should calculate the question weight correctly" do
      subject.question_weight.round(2).should == BigDecimal.new("3.33")
    end
  end

  context "when there arent results" do
    it "should calculate the average result" do
      subject.average_grade.should == BigDecimal.new('0')
    end
  end

  context "finalized by" do
    context "when the user finalized" do
      before do
        @user = Factory(:user)
        subject.start_for(@user)
        subject.finalize_for(@user)
      end

      it "should return true" do
        subject.finalized_by?(@user).should be_true
      end
    end

    context "when the user started but havent finalized" do
      before do
        @user = Factory(:user)
        subject.start_for(@user)
      end

      it "should return false" do
        subject.finalized_by?(@user).should be_false
      end
    end

    context "when there arent results at all" do
      it "should return false" do
        subject.finalized_by?(Factory(:user)).should be_false
      end
    end
  end

  context "when there are results" do
    before do
      3.times do
        result = Factory(:result,
                         :grade => BigDecimal.new("3.5"),
                         :state => 'finalized',
                         :exercise => subject)
        subject.results << result
      end

      3.times do
        result = Factory(:result,
                         :grade => BigDecimal.new("9.0"),
                         :exercise => subject,
                         :state => 'finalized')
        subject.results << result
      end
    end

    it "should calculate the average result correctly" do
      subject.average_grade.round(2).should == BigDecimal.new("6.25")
    end
  end

  context "when there aren't finalized results" do
    it "should not compute" do
      subject.results << Factory(:result)
      subject.average_grade.should == BigDecimal.new('0')
    end
  end

  context "when starting an exercise" do
    before do
      @user = Factory(:user)
    end

    it "responds to start_for" do
      subject.should respond_to(:start_for)
    end

    it "should create and start a result" do
      expect {
        subject.start_for(@user)
      }.should change(subject.results.started, :count).by(1)
    end

    context "when there are a waiting result" do
      before do
        @prev_result = subject.results.create(:user_id => @user.id)
      end

      it "shouldnt create another result" do
        subject.results.where(:user_id => @user).should_not be_empty
        expect {
          subject.start_for(@user)
        }.should_not change(subject.results, :count)
      end

      it "should destroy the previous result" do
        subject.start_for(@user)

        expect {
          @prev_result.reload
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when there are a started result" do
      before do
        @prev_result = subject.start_for(@user)
      end

      it "shouldnt create another result" do
        subject.results.where(:user_id => @user).should_not be_empty
        expect {
          subject.start_for(@user)
        }.should_not change(subject.results, :count)
      end

      it "should destroy the previous result" do
        subject.start_for(@user)

        expect {
          @prev_result.reload
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when there are a finalized result" do
      before do
        @prev_result = subject.start_for(@user)
        @prev_result.finalize!
      end

      it "shouldnt create another result" do
        expect {
          subject.start_for(@user)
        }.should_not change(subject.results, :count)
      end

      it "should return the finalized result" do
        result = subject.start_for(@user)
        result.should == @prev_result
      end
    end
  end

  context "when finalizing an exercise" do
    it "should respond to finalize_for" do
      subject.should respond_to(:finalize_for)
    end

    context "when the result is already finalized" do
      before do
        @user = Factory(:user)
        @result = subject.start_for(@user)
        @result.finalize!
      end

      it "should not finalize again" do
        Result.any_instance.should_not_receive('finalize!')
        subject.finalize_for(@user)
      end
    end

    context "when the result was started" do
      before do
        @user = Factory(:user)
        @result = subject.start_for(@user)
      end

      it "should finalize the result" do
        subject.finalize_for(@user)
        subject.finalized_by?(@user).should be_true
      end
    end
  end

  context "when getting choices from user" do
    subject { Factory(:complete_exercise) }

    before do
      @user = Factory(:user)
      @choices = subject.questions.collect do |q|
        q.choose_alternative(q.correct_alternative, @user)
      end
      Factory(:choice, :user => @user) # ruído
    end

    it "should get the correct choices" do
      subject.choices_for(@user).to_set == @choices.to_set
    end
  end

  context "when getting info" do
    subject { Factory(:complete_exercise) }

    it "should return the correct number of questions" do
      subject.info[:questions_count].should == 3
    end

    it "should return the correct number of explained questions" do
      subject.info[:explained_count].should == 0
    end

    it "should return the grade average" do
      subject.info[:average_grade].round(2) == BigDecimal.new("0.0")
    end

    it "should return the duration average" do
      subject.info[:average_duration] == 0
    end
  end

  context "when getting results" do
    subject { Factory(:complete_exercise) }
    before do
      @user = Factory(:user)
      subject.start_for(@user)
    end

    it "should return the correct result" do
      subject.finalize_for(@user)
      subject.result_for(@user).user.should == @user
    end
  end

  context "when verifying if anyone have finalized" do
    subject { Factory(:complete_exercise) }

    it "should return false when there arent any results" do
      subject.has_results?.should be_false
    end

    it "should return true when there are finalized results" do
      user = Factory(:user)
      subject.start_for(user)
      subject.finalize_for(user)

      subject.has_results?.should be_true
    end
  end
end

require 'spec_helper'

describe Exercise do
  subject { Factory(:exercise) }

  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:results).dependent(:destroy) }
  it { should have_many(:explained_questions) }
  it { should have_one(:lecture) }
  it { should accept_nested_attributes_for(:questions) }

  context "when validating questions count" do
    it "should add error when there arent questions" do
      subject.make_sense?.should_not be_true
      subject.errors.get(:base).should_not be_empty
    end

    it "should not add errors when there are questions" do
      exercise = Factory(:complete_exercise)
      exercise.make_sense?.should be_true
    end

    it "should add error when there are questions marked for destruction" do
      subject = Factory(:complete_exercise)
      questions = subject.questions
      mass = { :questions_attributes =>
               [{:id => questions[0].id, :_destroy => true},
                {:id => questions[1].id, :_destroy => true},
                {:id => questions[2].id, :_destroy => true}] }

     subject.attributes = mass
     subject.make_sense?.should_not be_true
    end
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
      }.to change(subject.results.started, :count).by(1)
    end

    context "when there are a waiting result" do
      before do
        @prev_result = subject.results.create(:user_id => @user.id)
      end

      it "shouldnt create another result" do
        subject.results.where(:user_id => @user).should_not be_empty
        expect {
          subject.start_for(@user)
        }.to_not change(subject.results, :count)
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
        }.to_not change(subject.results, :count)
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
        }.to_not change(subject.results, :count)
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

  context "when accepting nested attributes" do
    before do
      @exercise = Factory.build(:exercise)
    end

    context "when creating an exercise with blank question" do
      before do
        question_attrs = { :questions_attributes => {
          "1" => { :statement => "",
                   :alternatives_attributes => {
                     "1" =>  {:text => "", :correct => "0"},
                     "2" =>  {:text => "", :correct => "0"},
                     "3" =>  {:text => "", :correct => "0"}
                   }
                 },
          "2" => { :statement => "Lorem valid 2",
                   :alternatives_attributes => {
                     "1" =>  {:text => "Alternative 1", :correct => "0"},
                     "2" =>  {:text => "Alternative 2", :correct => "1"},
                     "3" =>  {:text => "Alternative 3", :correct => "0"}
                   }
                 },
        } }
        @exercise.attributes = question_attrs
      end

      it "exercise is valid" do
        @exercise.should be_valid
      end

      it "saves the exercise" do
        expect {
          @exercise.save
        }.to change(Exercise, :count).by(1)
      end

      it "saves only the complete questions" do
        expect {
          @exercise.save
        }.to change(Question, :count).by(1)
      end
    end

    context "when creating an exercise with almost blank exercise (has non-blank question)" do
      before do
        question_attrs = { :questions_attributes => {
          "1" => { :statement => "",
                   :alternatives_attributes => {
                     "1" =>  {:text => "Alternative 1", :correct => "1"},
                     "2" =>  {:text => "Alternative 2", :correct => "0"},
                     "3" =>  {:text => "Alternative 3", :correct => "0"}
                   }
                 },
          "2" => { :statement => "Lorem valid 2",
                   :alternatives_attributes => {
                     "1" =>  {:text => "Alternative 1", :correct => "0"},
                     "2" =>  {:text => "Alternative 2", :correct => "1"},
                     "3" =>  {:text => "Alternative 3", :correct => "0"}
                   }
                 },
        } }
        @exercise.attributes = question_attrs
      end

      it "exercise is not valid" do
        @exercise.should_not be_valid
      end

      it "question with valid alternatives but blank statement should it is not valid" do
        @exercise.questions.first.should_not be_valid
      end
    end

    context "when building nested" do
      before do
        @lecture = Lecture.new
        @lecture.build_lectureable(:_type => 'Exercise')
      end

      context "when the exercise does not have any question" do
        before do
          @lecture.lectureable.build_question_and_alternative
        end

        it "builds a question" do
          @lecture.lectureable.questions.should_not be_empty
        end

        it "builds a question within an alternative" do
          @lecture.lectureable.questions.first.alternatives.should_not be_empty
        end

        it "has just on question" do
          @lecture.lectureable.questions.should have(1).items
        end

        it "has just one alternative inside the question" do
          @lecture.lectureable.questions.first.alternatives.should have(1).items
        end
      end

      context "when the exercise has one question without alternatives" do
        before do
          @lecture.lectureable.questions << Factory(:question)
          @lecture.lectureable.build_question_and_alternative
        end

        it "builds an alternative inside the question" do
          @lecture.lectureable.questions.first.alternatives.should_not be_empty
        end

        it "has just on question" do
          @lecture.lectureable.questions.should have(1).items
        end

        it "has just one alternative inside the question" do
          @lecture.lectureable.questions.first.alternatives.should have(1).items
        end
      end

      context "when the exercise has one question with alternatives" do
        before do
          @alternatives = (1..3).collect { Factory.build(:alternative) }
          @question = Factory.build(:question, :alternatives => @alternatives)
          @lecture.lectureable.questions << @question
          @lecture.lectureable.build_question_and_alternative
        end

        it "has just on question" do
          @lecture.lectureable.questions.should have(1).items
        end

        it "has just the same quantity of alternatives inside the question" do
          @lecture.lectureable.questions.first.alternatives.
            should have(@alternatives.size).items
        end
      end
    end
  end
end

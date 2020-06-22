# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Result do
  subject { FactoryBot.create(:result) }

  # Rel
  it { should belong_to :exercise }
  it { should belong_to :user }
  it { should have_many(:choices).dependent(:destroy) }

  # Validation
  it { should validate_uniqueness_of(:user_id).scoped_to(:exercise_id) }


  context "state machine" do
    it "responds to transitions" do
      [:start!, :finalize!].each do |method|
        subject.should respond_to method
      end
    end

    it "defaults to waiting" do
      subject.waiting?.should == true
    end

    context "when starting" do
      it "should set started_at" do
        expect {
          subject.start!
        }.to change(subject, :started_at)

        subject.started_at.should be_within(1).of(Time.zone.now)
      end
    end

    context "when finalizing" do
      it "should set finalized_at" do
        subject.start!
        expect {
          subject.finalize!
        }.to change(subject, :finalized_at)
        subject.finalized_at.should be_within(1).of(Time.zone.now)
      end

      it "should calculate the grade" do
        subject.choices << 3.times.collect { FactoryBot.create(:choice, correct: true )}
        subject.exercise.stub(:question_weight) { BigDecimal.new("1.0") }
        subject.start!

        expect {
          subject.finalize!
        }.to change { subject.grade.try(:round,2) }.to(BigDecimal.new("3.0"))
      end

      it "should assign the exam choices" do
        Exercise.any_instance.should_receive(:choices_for).with(subject.user).
          and_return([])
        subject.start!
        subject.finalize!
      end
    end

  end

  context "calculations" do
    it "should have a grade even when is not finalized" do
      subject.choices << 3.times.collect { FactoryBot.create(:choice, correct: true )}
      subject.exercise.stub(:question_weight) { BigDecimal.new("1.0") }
      subject.calculate_grade.should == BigDecimal.new("3.0")
    end

    context "when finalized" do
      before do
        subject.exercise = FactoryBot.create(:exercise, maximum_grade: 10)
        subject.user = FactoryBot.create(:user)

        subject.start!

        subject.choices << 3.times.collect { FactoryBot.create(:choice, correct: true )}
        subject.exercise.stub(:question_weight) { BigDecimal.new("1.0") }
      end

      it "should calculate the grade" do
        subject.finalize!
        subject.exercise.should_receive(:question_weight)
        subject.calculate_grade.round(2).should == BigDecimal.new("3.0")
      end

      it "should calculate correct choices number" do
        subject.finalize!
        # Um pouco de ruído
        subject.choices << 3.times.collect { FactoryBot.create(:choice, correct: false )}
        subject.choices.correct.count.should == 3
      end

      it "should assing duration" do
        subject.finalize!
        subject.duration.should == (subject.finalized_at - subject.started_at).
          to_i
      end
    end
  end

  context "duration" do
    before do
      subject.exercise = FactoryBot.create(:exercise, maximum_grade: 10)
      subject.user = FactoryBot.create(:user)
    end

    it "should calculate the duartion" do
      subject.start! && subject.finalize!

      started_at  = Time.zone.now
      finalized_at = started_at + 1.day
      subject.update_attributes({ started_at: started_at })
      subject.update_attributes({ finalized_at: finalized_at })

      subject.calculate_duration.should == (finalized_at - started_at)
    end

    it "should return 0 if is not finalized" do
      subject.calculate_duration.should == 0
    end
  end

  context "scope" do
    it "should scope by n recents" do
      subject.start! && subject.finalize!
      subject.update_attribute(:finalized_at, (Time.zone.now - 3.days))

      results = 3.times.collect do |i|
        result = FactoryBot.create(:result)
        result.start! && result.finalize!
      end

      Result.n_recents(3).to_set == results.to_set
    end

    it "should scope by best grades" do
      subject.start! && subject.finalize!
      subject.update_attribute(:grade, 5)

      results = 3.times.collect do |i|
        result = FactoryBot.create(:result, grade: 10)
        result.start! && result.finalize!
      end

      Result.n_best_grades(3).to_set == results.to_set
    end
  end

  context "when generating report" do
    before do
      subject.start!
      subject.exercise = FactoryBot.create(:exercise, maximum_grade: 10)
      20.times { subject.exercise.questions << FactoryBot.create(:question) }
      10.times.collect do  |i|
        response = (i % 2 == 0) ? true : false
        subject.choices << FactoryBot.create(:choice, correct: response)
      end
      subject.finalize!
    end

    it "should have the correct keys" do
      [:hits, :misses, :blanks, :duration, :grade].each do |key|
        subject.to_report.should have_key(key)
      end
    end

    it "should generate the correct hits" do
      subject.to_report.fetch(:hits).should == 5
    end

    it "should generate the misses" do
      subject.to_report.fetch(:misses).should == 5
    end

    it "should generate the blank questions number" do
      subject.to_report.fetch(:blanks).should == 10
    end

    it "should generate the grade" do
      subject.to_report.fetch(:grade).round(2).should == BigDecimal.new("2.5")

    end
  end
end

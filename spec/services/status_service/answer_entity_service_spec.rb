require 'spec_helper'

module StatusService
  describe AnswerEntityService do
    subject { AnswerEntityService.new }
    let(:activity) { FactoryGirl.build_stubbed(:activity) }

    context "#create" do
      let(:fake_answer) { mock_model('Answer') }
      let(:answer_params) do
        FactoryGirl.attributes_for(:answer)
      end

      it "should delegate to #status.answers.build" do
        activity.stub_chain(:answers, :build)
        fake_answer.stub(:save)
        activity.answers.should_receive(:build).with(answer_params).
          and_return(fake_answer)

        subject.create(activity, answer_params)
      end

      it "should yield with the Answer" do
        expect { |b| subject.create(activity, answer_params, &b) }.to \
          yield_with_args(Answer)
      end

      it "should set the status as Answer#in_response_to" do
        subject.create(activity, answer_params) do |a|
          a.in_response_to.should == activity
        end
      end

      it "shold return the answer" do
        subject.create(activity, answer_params).should be_a Answer
      end

      it "should create the answer" do
        activity = FactoryGirl.create(:activity)
        expect {
          subject.create(activity, answer_params) do |a|
            a.user = activity.user
          end
        }.to change(Answer, :count).by(1)

      end
    end
  end
end

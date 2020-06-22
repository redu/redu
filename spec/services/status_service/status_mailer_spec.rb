require 'spec_helper'

module StatusService
  module Mailers
    describe StatusMailer do
      subject { StatusMailer }
      let(:user) { FactoryBot.build_stubbed(:user) }
      let(:answer) { FactoryBot.build_stubbed(:answer) }
      let(:notification) do
        AnswerService::AnswerNotification.new(user: user, answer: answer)
      end

      context ".new_answer" do
        xit "should deliver answer notification" do
          expect {
            subject.new_answer(notification).deliver
          }.to change(subject.deliveries, :length).by(1)
        end
      end
    end
  end
end

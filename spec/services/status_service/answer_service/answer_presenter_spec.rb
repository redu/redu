# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  module AnswerService
    describe AnswerPresenter do
      include ActionView::TestCase::Behavior

      let(:author) { FactoryBot.build_stubbed(:user) }
      let(:user) { FactoryBot.build_stubbed(:user) }
      let(:answer) do
        FactoryBot.build_stubbed(:answer, user: author, in_response_to: status)
      end
      let(:status) { FactoryBot.build_stubbed(:activity) }
      let(:notification) { AnswerNotification.new }
      subject { AnswerPresenter.new(notification: notification, template: view) }


      it "should degine author_link" do
        notification.stub(:answer).and_return(answer)
        subject.author_link.should =~ /href=\"#{view.user_url(author)}\"/
      end

      it "should define answer_link" do
        notification.stub(:answer).and_return(answer)
        subject.answer_link.should =~ /href=\"#{view.status_url(answer)}\"/
      end

      shared_examples_for "email notification" do
        let(:notification) do
          AnswerNotification.new(user: user, answer: answer)
        end
        it "should generate the correct #action" do
          subject.action.should =~ message
        end

        it "should generate the correct #subject" do
          subject.subject.should =~ /#{author.first_name} #{message}/
        end
      end

      context "when status#statusable is User" do
        it_should_behave_like "email notification" do
          let(:status) { FactoryBot.build_stubbed(:activity, user: user) }
          let(:message) do
            /participou da discussão no Mural de #{status.statusable.first_name}/
          end
        end
      end

      context "when status#statusable is Lecture" do
        it_should_behave_like "email notification" do
          let(:lecture) { FactoryBot.build_stubbed(:lecture) }
          let(:status) do
            FactoryBot.build_stubbed(:activity, user: user, statusable: lecture)
          end
          let(:message) do
            /participou da discussão em: #{lecture.name}/
          end
        end
      end

      context "when status#statusable is Space" do
        it_should_behave_like "email notification" do
          let(:space) { FactoryBot.build_stubbed(:space) }
          let(:status) do
            FactoryBot.build_stubbed(:activity, user: user, statusable: space)
          end
          let(:message) do
            /participou da discussão em: #{space.name}/
          end
        end
      end

      context "#template" do
        it "should raise a runtime error when there is no template" do
          msg = \
            "No template defined. You need to pass :template to new or use #context"

          expect {
            AnswerPresenter.new.template
          }.to raise_error /#{msg}/
        end
      end

      context "#context" do
        it "should yield controll with AnswerPresenter" do
          expect { |b| subject.context(view, &b) }.to yield_with_args(subject)
        end

        it "should keep the original template" do
          subject.context("blah!")
          subject.template.should == view
        end

        it "should ensure original template" do
          begin
            subject.context("blah!") do
              raise "exception"
            end
          rescue Exception
          end

          subject.template.should == view
        end
      end
    end
  end
end

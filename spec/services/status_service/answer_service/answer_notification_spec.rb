require 'spec_helper'

module StatusService
  module AnswerService
    describe AnswerNotification do
      let(:author) { FactoryGirl.build_stubbed(:user) }
      let(:user) { FactoryGirl.build_stubbed(:user) }
      let(:answer) do
        FactoryGirl.build_stubbed(:answer, user: author, in_response_to: status)
      end
      let(:status) { FactoryGirl.build_stubbed(:activity) }
      subject { AnswerNotification.new(answer: answer, user: user) }

      it "should define author_name" do
        subject.author_name.should == author.display_name
      end

      it "should define author_avatar" do
        subject.author_avatar(:thumb_32).should == author.avatar(:thumb_32)
      end

      it "should define answer_text" do
        subject.answer_text.should == answer.text
      end

      it "should define original author" do
        subject.original_author.should == status.user
      end

      context "#hierarchy_breadcrumb" do
        let(:user) { FactoryGirl.build_stubbed(:user) }
        let(:course) { FactoryGirl.build_stubbed(:course, owner: user) }
        let(:space) { FactoryGirl.build_stubbed(:space, course: course, owner: user) }
        let(:answer) do
          opts = { user: author, in_response_to: status, statusable: status }
          FactoryGirl.build_stubbed(:answer, opts)
        end

        context "when statusable is Lecture" do
          let(:subj) do
            FactoryGirl.build_stubbed(:subject, owner: user, space: space)
          end
          let(:lecture) do
            opts = { subject: subj, owner: user, lectureable: nil }
            FactoryGirl.build_stubbed(:lecture, opts)
          end
          let(:status) { FactoryGirl.build_stubbed(:activity, statusable: lecture) }

          it "should return the breadcrumb as Subject#name > Lecture#name" do
            subject.hierarchy_breadcrumbs.should == "#{subj.name} > #{lecture.name}"
          end
        end

        context "when statusable is Space" do
          let(:status) { FactoryGirl.build_stubbed(:activity, statusable: space) }

          it "should return the breadcrumb as Course#name > Space#name" do
            subject.hierarchy_breadcrumbs.should == "#{course.name} > #{space.name}"
          end
        end

        context "when statusable is User" do
          it "should return the breadcrumb as User#display_name" do
            subject.hierarchy_breadcrumbs.should == "#{status.statusable.display_name}"
          end
        end

        context "when statusable is something else" do
          it "should return empty string" do
            status.stub(:statusable).and_return(FactoryGirl.build_stubbed(:course))
            subject.hierarchy_breadcrumbs.should == ""
          end
        end
      end
    end
  end
end

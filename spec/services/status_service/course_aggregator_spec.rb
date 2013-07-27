# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe CourseAggregator do
    subject { described_class.new(course) }
    let(:course) { FactoryGirl.build_stubbed(:course) }

    describe "#perform" do
      it "should include the course" do
        expect(subject.perform).to include(courses: [course])
      end

      context "when there are other spaces from other courses" do
        let!(:spaces) do
          FactoryGirl.create_list(:space, 2, course: course)
        end
        let!(:other_spaces) do
          FactoryGirl.create_list(:space, 2)
        end

        it "should include all spaces from this course" do
          expect(subject.perform).to include(spaces: spaces)
        end
      end

      context "when there are many lectures" do
        let(:space) do
          FactoryGirl.create(:space, course: course)
        end
        let(:subj) do
          FactoryGirl.create(:subject, space: space, finalized: true)
        end
        let!(:lectures) do
          FactoryGirl.create_list(:lecture, 2, subject: subj)
        end
        let!(:other_lectures) do
          FactoryGirl.create_list(:lecture, 2)
        end

        it "should include all spaces from this course" do
          expect(subject.perform).to include(lectures: lectures)
        end
      end
    end
  end
end

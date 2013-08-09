# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe CourseAggregator do
    subject { described_class.new(course) }
    let(:course) { FactoryGirl.build_stubbed(:course) }

    describe "#perform" do
      it "should include the course" do
        expect(subject.perform).to include(Course: [course.id])
      end

      context "when there are other spaces from other courses" do
        before do
          FactoryGirl.create_list(:space, 2)
        end

        let!(:spaces) do
          FactoryGirl.create_list(:space, 2, course: course)
        end

        it "should include all spaces from this course" do
          expect(subject.perform).to include(Space: spaces.map(&:id))
        end
      end

      context "when there are many lectures" do
        before do
          FactoryGirl.create_list(:lecture, 2)
        end

        let!(:lectures) do
          space = FactoryGirl.create(:space, course: course)
          subj = FactoryGirl.create(:subject, space: space, finalized: true)
          FactoryGirl.create_list(:lecture, 2, subject: subj)
        end

        it "should include all spaces from this course" do
          expect(subject.perform).to include(Lecture: lectures.map(&:id))
        end
      end
    end
  end
end

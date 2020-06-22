# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe CourseHierarchyAggregator do
    subject { described_class.new(course) }
    let(:course) { FactoryBot.build_stubbed(:course) }

    describe "#build" do
      it "should include the course" do
        expect(subject.build).to include(Course: [course.id])
      end

      context "when there are other spaces from other courses" do
        before do
          FactoryBot.create_list(:space, 2)
        end

        let!(:spaces) do
          FactoryBot.create_list(:space, 2, course: course)
        end

        it "should include all spaces from this course" do
          expect(subject.build).to include(Space: spaces.map(&:id))
        end
      end

      context "when there are many lectures" do
        before do
          FactoryBot.create_list(:lecture, 2)
        end

        let!(:lectures) do
          space = FactoryBot.create(:space, course: course)
          subj = FactoryBot.create(:subject, space: space, finalized: true)
          FactoryBot.create_list(:lecture, 2, subject: subj)
        end

        it "should include all spaces from this course" do
          expect(subject.build).to include(Lecture: lectures.map(&:id))
        end
      end
    end
  end
end

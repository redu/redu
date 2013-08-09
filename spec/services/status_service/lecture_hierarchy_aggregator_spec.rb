# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe LectureHierarchyAggregator do
    subject { described_class.new(lecture) }
    let(:lecture) { FactoryGirl.build_stubbed(:lecture) }

    describe "#build" do
      it "should include the lecture" do
        expect(subject.build).to include(Lecture: [lecture.id])
      end
    end
  end
end

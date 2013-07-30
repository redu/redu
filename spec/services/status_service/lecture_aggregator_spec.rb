# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe LectureAggregator do
    subject { described_class.new(lecture) }
    let(:lecture) { FactoryGirl.build_stubbed(:lecture) }

    describe "#perform" do
      it "should include the lecture" do
        expect(subject.perform).to include(Lecture: [lecture.id])
      end
    end
  end
end

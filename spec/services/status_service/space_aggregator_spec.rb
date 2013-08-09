# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe SpaceAggregator do
    subject { described_class.new(space) }
    let(:space) { FactoryGirl.build_stubbed(:space) }

    describe "#perform" do
      it "should include the space" do
        expect(subject.perform).to include(Space: [space.id])
      end

      context "when there are other spaces lectures" do
        before do
          FactoryGirl.create_list(:lecture, 2)
        end

        let!(:lectures) do
          subj = FactoryGirl.create(:subject, space: space, finalized: true)
          FactoryGirl.create_list(:lecture, 2, subject: subj)
        end

        it "should include all lectures from this space" do
          expect(subject.perform).to include(Lecture: lectures.map(&:id))
        end
      end
    end
  end
end

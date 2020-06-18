# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe SpaceHierarchyAggregator do
    subject { described_class.new(space) }
    let(:space) { FactoryBot.build_stubbed(:space) }

    describe "#build" do
      it "should include the space" do
        expect(subject.build).to include(Space: [space.id])
      end

      context "when there are other spaces lectures" do
        before do
          FactoryBot.create_list(:lecture, 2)
        end

        let!(:lectures) do
          subj = FactoryBot.create(:subject, space: space, finalized: true)
          FactoryBot.create_list(:lecture, 2, subject: subj)
        end

        it "should include all lectures from this space" do
          expect(subject.build).to include(Lecture: lectures.map(&:id))
        end
      end
    end
  end
end

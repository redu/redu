# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe SpaceAggregator do
    subject { described_class.new(space) }
    let(:space) { FactoryGirl.create(:space) }

    describe "#perform" do
      it "should include the space" do
        expect(subject.perform).to include(spaces: [space])
      end

      context "when there are other spaces lectures" do
        let(:subj) do
          FactoryGirl.create(:subject, space: space, finalized: true)
        end
        let!(:lectures) do
          FactoryGirl.create_list(:lecture, 2, subject: subj)
        end
        let!(:other_lectures) do
          FactoryGirl.create_list(:lecture, 2)
        end

        it "should include all lectures from this space" do
          expect(subject.perform).to include(lectures: lectures)
        end
      end
    end
  end
end

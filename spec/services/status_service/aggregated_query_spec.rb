# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe AggregatedQuery do
    subject { described_class.new(aggregator) }
    let(:space) { FactoryGirl.create(:space) }
    let(:aggregator) { mock("Aggregator", perform: { spaces: [space] }) }

    describe ".new" do
      let!(:statuses) do
        FactoryGirl.create_list(:activity, 2, statusable: space)
      end
      let!(:other_status) do
        FactoryGirl.create(:activity)
      end

      it "should contruct the query" do
        expect(subject.relation).to eq(statuses)
      end

      context "when a specific relation is passed" do
        subject do
          described_class.new(aggregator, Status.where(text: "Cool"))
        end

        let!(:status) do
          status_with_cool_text(statuses)
        end

        it "should apply this relation to the query" do
          expect(subject.relation).to match_array([status])
        end
      end
    end

    it "should be possible to change the aggregator" do
      expect(subject).to respond_to(:aggregator=)
    end

    def status_with_cool_text(statuses)
      statuses.last.update_attributes(text: "Cool")
      statuses.last
    end
  end
end

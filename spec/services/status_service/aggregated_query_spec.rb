# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe AggregatedQuery do
    subject { described_class.new(space) }
    let(:space) { FactoryGirl.create(:space) }

    describe "#count" do
      let!(:statuses) do
        FactoryGirl.create_list(:activity, 2, statusable: space)
      end
      let!(:other_status) do
        FactoryGirl.create(:activity)
      end

      it "should count the matched statuses" do
        expect(subject.count).to eq(statuses.length)
      end

      context "when a specific relation is passed" do
        subject do
          described_class.new(space, Status.where(text: "Cool"))
        end

        let!(:status) do
          status_with_cool_text(statuses)
        end

        it "should apply this relation to the query" do
          expect(subject.count).to eq(1)
        end
      end
    end

    describe "#find_each" do
      let!(:statuses) do
        FactoryGirl.create_list(:activity, 2, statusable: space)
      end
      let!(:other_status) do
        FactoryGirl.create(:activity)
      end

      it "should yield to Status.find_each with matched statuses" do
        expect { |b| subject.find_each(&b) }.to yield_successive_args(*statuses)
      end

      context "when a specific relation is passed" do
        subject do
          described_class.new(space, Status.where(text: "Cool"))
        end

        let!(:status) do
          status_with_cool_text(statuses)
        end

        it "should apply this relation to the query" do
          expect { |b| subject.find_each(&b) }.to yield_successive_args(status)
        end
      end
    end

    def status_with_cool_text(statuses)
      statuses.last.update_attributes(text: "Cool")
      statuses.last
    end
  end
end

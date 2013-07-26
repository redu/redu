# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe FromHierarchyStatusQuery do
    subject { FromHierarchyStatusQuery.new(space) }
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
          FromHierarchyStatusQuery.new(space, Status.where(text: "Cool"))
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
          FromHierarchyStatusQuery.new(space, Status.where(text: "Cool"))
        end

        let!(:status) do
          status_with_cool_text(statuses)
        end

        it "should apply this relation to the query" do
          expect { |b| subject.find_each(&b) }.to yield_successive_args(status)
        end
      end
    end

    describe "#build_conditions" do
      let(:users) { FactoryGirl.build_stubbed_list(:user, 2)}
      let(:courses) { FactoryGirl.build_stubbed_list(:course, 2)}
      let(:space) { FactoryGirl.build_stubbed(:space)}
      let(:statusables) { { user: users, course: courses, space: [space] } }

      before do
        subject.stub(:statuables_on_hierarchy).and_return(statusables)
      end

      it "should invoke self.statuables_on_hierarchy" do
        subject.should_receive(:statuables_on_hierarchy)
        subject.build_conditions
      end

      it "should construct the sql conditions for the statusables" do
        expect(subject.build_conditions).to \
          eq [statusable_condition(users), statusable_condition(courses),
              statusable_condition(space)].join(" OR ")
      end

      context "when there aren't statuses for some hierarchy level" do
        let(:statusables) { { user: users, space: [] } }

        it "should not include clause for this level" do
        expect(subject.build_conditions).to \
          eq statusable_condition(users)
        end
      end

      def statusable_condition(entity)
        entities = entity.respond_to?(:each) ? entity : [entity]

        ids = entities.collect(&:id).join(",")
        klass = entities.first.class
        "(statusable_type LIKE '#{klass}' AND statusable_id IN (#{ids}))"
      end
    end

    def status_with_cool_text(statuses)
      statuses.last.update_attributes(text: "Cool")
      statuses.last
    end
  end
end

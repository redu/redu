# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe FromHierarchyStatusQuery do
    subject { FromHierarchyStatusQuery.new }

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
        subject.build_conditions(Object)
      end

      it "should construct the sql conditions for the statusables" do
        expect(subject.build_conditions(Object)).to \
          eq [statusable_condition(users), statusable_condition(courses),
              statusable_condition(space)].join(" OR ")
      end

      context "when there aren't statuses for some hierarchy level" do
        let(:statusables) { { user: users, space: [] } }

        it "should not include clause for this level" do
        expect(subject.build_conditions(Object)).to \
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
  end
end

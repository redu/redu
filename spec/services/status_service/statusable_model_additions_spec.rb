# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  module StatusableAdditions
    describe ModelAdditions do
      class ::Dummy
        include BaseModelAdditions
        include ModelAdditions
      end
      class StatusService::DummyHierarchyAggregator < Struct.new(:dummy) ; end

      subject { ::Dummy.new }
      let(:facade) { mock("Facade") }

      describe "#activities" do
        it "should invoke Facade#activities with aggregator and relation" do
          mock_facade(facade)
          facade.should_receive(:activities).
            with(DummyHierarchyAggregator.new(subject),
                 an_instance_of(ActiveRecord::Relation))

          subject.activities
        end
      end

      def mock_facade(m)
        Facade.stub(:instance).and_return(m)
      end
    end
  end
end

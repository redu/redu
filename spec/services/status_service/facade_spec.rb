# -*- encoding : utf-8 -*-
require "spec_helper"

module StatusService
  describe Facade do
    subject { Facade.instance }
    let(:status_entity_service) { mock("StatusEntityService") }
    let(:status_dependencies_entity_service) do
      mock("StatusDependenciesEntityService")
    end

    describe "#destroy_status" do
      let(:statusable) { FactoryGirl.build_stubbed(:user) }

      before do
        mock_status_entity_service(status_entity_service)
        mock_status_dependencies_entity_service(status_dependencies_entity_service)
      end

      context "services initialization" do
        before do
          status_dependencies_entity_service.stub(:destroy)
          status_entity_service.stub(:destroy)
        end

        it "should invoke StatusEntityService.new with statusable" do
          status_entity_service.stub(:statuses)

          StatusEntityService.should_receive(:new).
            with({ statusable: statusable })
          subject.destroy_status(statusable)
        end

        it "should invoke StatusEntityService#statuses with statusable" do
          status_entity_service.should_receive(:statuses).with(no_args())
          subject.destroy_status(statusable)
        end

        it "should invoke StatusDependenciesEntityService.new with" \
          " StatusEntityService#statuses return" do
          statuses = FactoryGirl.build_stubbed_list(:activity, 2)
          status_entity_service.stub(:statuses).and_return(statuses)

          StatusDependenciesEntityService.should_receive(:new).
            with({ statuses: statuses })
          subject.destroy_status(statusable)
        end
      end

      it "should invoke StatusEntityService#destroy without args" do
        status_entity_service.stub(:statuses)
        status_dependencies_entity_service.stub(:destroy)

        status_entity_service.should_receive(:destroy).with(no_args())
        subject.destroy_status(statusable)
      end


      it "should invoke StatusDependenciesEntityService#destroy without args" do
        status_entity_service.stub(:statuses)
        status_entity_service.stub(:destroy)

        status_dependencies_entity_service.should_receive(:destroy).
          with(no_args())
        subject.destroy_status(statusable)
      end
    end

    def mock_status_entity_service(m)
      StatusEntityService.stub(:new).and_return(m)
    end

    def mock_status_dependencies_entity_service(m)
      StatusDependenciesEntityService.stub(:new).and_return(m)
    end

    context "#answer_status" do
      let(:notification_service) { AnswerService::AnswerNotificationService }
      let(:entity_service) { mock('AnswerEntityService') }
      let(:activity) { FactoryGirl.build_stubbed(:activity) }
      let(:attributes) { FactoryGirl.attributes_for(:answer) }
      before { subject.stub(:answer_service).and_return entity_service }

      it "should invoke AnswerEntityService with correct arguments" do
        entity_service.should_receive(:create).with(activity, attributes)
        subject.answer_status(activity, attributes)
      end

      it "should return an Answer" do
        answer = mock_model('Answer')

        entity_service.stub(:create).and_return(answer)
        notification_service.stub_chain(:new, :deliver)

        subject.answer_status(mock_model('Activity'), {}).should == answer
      end

      it "should invoke AnswerNotificationService" do
        answer = mock_model('Answer')
        entity_service.stub(:create).and_return(answer)

        notification_service.should_receive(:new).
          with(answer).and_call_original
        notification_service.any_instance.should_receive(:deliver)

        subject.answer_status(activity, attributes) do |a|
          a.user = FactoryGirl.build_stubbed(:user)
        end
      end
    end

    describe "#activites" do
      let(:aggregator) { mock("Aggregator") }
      let(:aggregated_query) { mock("AggregatedQuery") }

      it "should invoke initialize an AggregatedQuery with aggregator" do
        aggregated_query.stub(:relation)

        AggregatedQuery.should_receive(:new).with(aggregator).
          and_return(aggregated_query)

        subject.activities(aggregator)
      end

      it "should invoke AggregatedQuery#relation" do
        AggregatedQuery.stub(:new).and_return(aggregated_query)

        aggregated_query.should_receive(:relation).with(no_args())
        subject.activities(aggregator)
      end
    end
  end
end

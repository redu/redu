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
      let(:statusable) { FactoryGirl.create(:user) }

      before do
        mock_status_entity_service(status_entity_service)
        mock_status_dependencies_entity_service(status_dependencies_entity_service)
      end

      context "services initialization" do
        before do
          status_dependencies_entity_service.stub(:destroy)
          status_entity_service.stub(:destroy)
        end

        it "should invoke StatusEntityService#new with statusable" do
          StatusEntityService.should_receive(:new).
            with({ statusable: statusable })
          subject.destroy_status(statusable)
        end

        it "should invoke StatusDependenciesEntityService#new with" \
          " statusable" do
          StatusDependenciesEntityService.should_receive(:new).
            with({ statusable: statusable })
          subject.destroy_status(statusable)
        end
      end

      it "should invoke StatusEntityService#destroy without args" do
        status_dependencies_entity_service.stub(:destroy)

        status_entity_service.should_receive(:destroy).with(no_args())
        subject.destroy_status(statusable)
      end


      it "should invoke StatusDependenciesEntityService#destroy without args" do
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
  end
end

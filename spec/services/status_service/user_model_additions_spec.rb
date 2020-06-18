# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe User do
    subject { FactoryBot.create(:user) }
    let(:facade) { mock("Facade") }

    describe "before_destroy" do
      it "should invoke User#destroy_statuses" do
        subject.should_receive(:destroy_statuses).with(no_args())
        subject.destroy
      end
    end

    describe "#destroy_statuses" do
      it "should invoke Facade#destroy_status with self" do
        mock_facade(facade)
        facade.should_receive(:destroy_status).with(subject)
        subject.send(:destroy_statuses)
      end
    end

    def mock_facade(m)
      Facade.stub(:instance).and_return(m)
    end
  end
end

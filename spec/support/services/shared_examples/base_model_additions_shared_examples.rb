# -*- enconding : utf-8 -*-
shared_examples_for "BaseModelAdditions" do |service|
  let(:service_name) { service.to_s.underscore }

  class DummyClass ; end

  before do
    base_additions = described_class
    DummyClass.class_eval do
      include base_additions
    end

    service::Facade.stub(:instance).and_return(facade)
  end

  let(:dummy_class) { DummyClass }
  let(:dummy) { DummyClass.new }
  let(:facade) { mock("Facade") }

  describe "##{service.to_s.underscore}" do
    it "should respond" do
      dummy.should respond_to(service_name)
    end

    it "should return the Facade" do
      dummy.send(service_name).should == facade
    end
  end

  describe ".#{service.to_s.underscore}" do
    it "should respond" do
      dummy_class.should respond_to(service_name)
    end

    it "should return the Facade" do
      dummy_class.send(service_name).should == facade
    end
  end
end

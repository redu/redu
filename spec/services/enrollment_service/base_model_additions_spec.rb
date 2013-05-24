# -*- enconding : utf-8 -*-
module EnrollmentService
  describe BaseModelAdditions do
    class DummyClass
      include BaseModelAdditions
    end

    let(:dummy_class) { DummyClass }
    let(:dummy) { DummyClass.new }

    describe "#enrollment_service" do
      let(:facade) { mock(Facade) }

      before do
        Facade.stub(:instance).and_return(facade)
      end

      it "should return the Facade" do
        dummy.enrollment_service.should == facade
      end
    end

    describe ".enrollment_service" do
      let(:facade) { mock(Facade) }

      before do
        Facade.stub(:instance).and_return(facade)
      end

      it "should return the Facade" do
        dummy_class.enrollment_service.should == facade
      end
    end
  end
end

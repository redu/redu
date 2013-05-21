# -*- encoding : utf-8 -*-
require "spec_helper"

module EnrollmentService
  describe BulkMapper do
    let(:columns)  { [:foo, :bar] }
    let(:concrete_class) { mock('Class') }
    subject { BulkMapper.new(concrete_class, columns, :foo => :bar) }

    context "#insert" do
      it "should delegate to ActiveRecor.import" do
        concrete_class.should_receive(:import)
        subject.insert([])
      end

      it "should permit options overloading" do
        concrete_class.should_receive(:import).with(columns, [], :foo => :xar)
        subject.insert([], :foo => :xar)
      end
    end
  end
end

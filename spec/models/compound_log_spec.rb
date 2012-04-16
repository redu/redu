require 'spec_helper'

describe CompoundLog do
  subject { Factory(:compound_log) }

  it { should have_many :logs }

  context "when deleting compound log" do
    before do
      @log = Factory(:log)
      subject.logs << @log
    end

    it "should delete successfully" do
      subject.destroy.should == subject
    end

    it "should delete all compounded logs" do
      expect {
        subject.destroy
      }.should change(Log, :count).by(-2)
    end
  end

end
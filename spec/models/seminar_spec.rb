require 'spec_helper'

describe Seminar do
  subject { Factory(:seminar) }

  it "should have one lecture" do
    pending "Need seminar factory" do
      should have_one :lecture
    end
  end

  it "validates youtube URL"
  it "truncates youtube URL"

  context "#external_resource_url" do
    subject { Factory(:seminar_youtube) }

    it "should return fully fladged URL" do
      subject.external_resource_url.should == \
        "http://www.youtube.com/watch?v=#{subject.external_resource}"
    end

    context do
      subject { Factory(:seminar_upload) }
      it "should return nil when there isn't a external_resource" do
        subject.external_resource_url.should be_nil
      end
    end
  end

end

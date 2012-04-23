require 'spec_helper'

describe Document do
  it { should have_attached_file(:attachment) }

  context "validates" do
    it "the content_type" do
      doc = Document.new
      doc.stub(:attachment_content_type) { "application/fay" }

      doc.should_not be_valid
      doc.errors[:attachment_content_type].should_not be_empty
    end
  end

  context "scribdfu" do
    before do
      @file = mock("attached_file",
                   :url => "http://test.com/path/to/somewhere",
                   :path => "/path/to/somewhere", :options => {})
      @document = Document.new
      @document.stub(:attachment) { @file }
      @document.stub('scribdable?') { true }

      mock_scribd_api
    end

    it "should upload to scribd" do
      values = {:ipaper_id => 'doc_id', :ipaper_access_key => 'access_key'}
      @document.should_receive(:update_attributes).with(values)
      @document.save
    end
  end

end

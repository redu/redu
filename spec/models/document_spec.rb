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
      @document = Document.new(:ipaper_id => 123456,
                               :ipaper_access_key => "abcdef")
      @document.stub(:attachment) { @file }
      @document.stub('scribdable?') { true }

      mock_scribd_api
    end

    it "should upload to scribd" do
      values = {:ipaper_id => 'doc_id', :ipaper_access_key => 'access_key'}
      @document.should_receive(:update_attributes).with(values)
      @document.save
    end

    it "returns the document's url on scribd" do
      @document.scribd_url.should == "http://www.scribd.com/embeds/123456/" \
        "content?start_page=1&view_mode=list&access_key=abcdef"
    end
  end

end

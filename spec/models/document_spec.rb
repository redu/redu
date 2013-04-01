require 'spec_helper'

describe Document do
  subject { Factory.build(:document) }

  it { should have_attached_file(:attachment) }

  describe "validates" do
    context "content_type" do
      it "should be invalid for not acceptable types" do
        subject.attachment_content_type = "application/fay"

        subject.should_not be_valid
        subject.errors[:attachment_content_type].should_not be_empty
      end

      it "should be valid for document types" do
        subject.attachment_content_type = "application/pdf"
        subject.should be_valid
      end
    end
  end

  context "scribdfu" do
    before do
      @file = File.open("#{Rails.root}/spec/fixtures/api/pdf_example.pdf")
      @document = Document.new(:ipaper_id => 123456,
                               :ipaper_access_key => "abcdef",
                               :attachment => @file)
      @document.stub('scribdable?') { true }

      mock_scribd_api
    end
    after { @file.close }

    context "#upload_to_scribd" do
      it "should upload to scribd" do
        values = {:ipaper_id => 'doc_id', :ipaper_access_key => 'access_key'}
        @document.should_receive(:update_attributes).with(values)
        @document.save
      end
    end

    context "#scribd_url" do
      it "returns the document's url on scribd" do
        @document.scribd_url.should == "http://www.scribd.com/embeds/123456/" \
          "content?start_page=1&view_mode=list&access_key=abcdef"
      end
    end

    it "returns the document's url on scribd" do
      @document.scribd_url.should == "http://www.scribd.com/embeds/123456/" \
        "content?start_page=1&view_mode=list&access_key=abcdef"
    end
  end
end

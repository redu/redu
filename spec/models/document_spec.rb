require 'spec_helper'

describe Document do
  subject { Factory(:document) }

  it { should have_attached_file(:attachment) }
  xit { should validate_attachment_content_type(:attachment) }
  xit { should validate_attachment.size(:attachment).
                less_than(2.megabytes) }

  context "validates" do
    it "a content_type" do
      path = File.join(Rails.root,
                       "spec",
                       "support",
                       "documents",
                       "document_test_fail.fai")

      doc = Factory.build(:document,
                          :attachment => File.new(path))
      doc.should_not be_valid
      doc.errors.on(:attachment).should_not be_nil
    end
  end

end

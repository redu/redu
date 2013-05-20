# -*- encoding : utf-8 -*-
require "spec_helper"

describe Myfile do
  subject { Factory(:myfile, :folder => @folder) }
  before do
    @space = Factory(:space)
    @folder = @space.folders.find_by_name("root")
    @another_folder = @space.folders.create(:name => "another")
  end

  context "when creating a file with existing title in different folders" do
    it "should reemove the current one" do
      Factory(:myfile, :folder => @another_folder,
              :attachment_file_name => subject.attachment_file_name)
      expect { subject.reload }.to_not raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when creating a file with existing title in same folder" do
    it "should not be valid" do
      f = Factory.build(:myfile, :folder => @folder,
              :attachment_file_name => subject.attachment_file_name)

      f.valid?
      f.errors[:attachment_file_name].should_not be_empty
    end
  end

  describe "validates" do
    context "content_type" do
      it "should be invalid for not acceptable types" do
        subject.attachment_content_type = "application/fay"

        subject.should_not be_valid
        subject.errors[:attachment_content_type].should_not be_empty
      end

      it "should be valid for image types" do
        subject.attachment_content_type = "image/jpeg"
        subject.should be_valid
      end

      it "should be valid for document types" do
        subject.attachment_content_type = "application/pdf"
        subject.should be_valid
      end

      it "should be valid for audio types" do
        subject.attachment_content_type = "audio/mp3"
        subject.should be_valid
      end
    end
  end
end

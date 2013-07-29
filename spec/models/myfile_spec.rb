# -*- encoding : utf-8 -*-
require "spec_helper"

describe Myfile do
  subject { FactoryGirl.create(:myfile, :folder => @folder) }
  before do
    @space = FactoryGirl.create(:space)
    @folder = @space.folders.find_by_name("root")
    @another_folder = @space.folders.create(:name => "another")
  end

  context "when creating a file with existing title in different folders" do
    it "should reemove the current one" do
      FactoryGirl.create(:myfile, :folder => @another_folder,
              :attachment_file_name => subject.attachment_file_name)
      expect { subject.reload }.to_not raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when creating a file with existing title in same folder" do
    it "should not be valid" do
      f = FactoryGirl.build(:myfile, :folder => @folder,
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

  describe ".recent" do
    it "should return an Arel" do
      expect(Myfile.recent).to be_a ActiveRecord::Relation
    end

    context "when there are old myfiles" do
      let!(:old_myfiles) do
        (2..3).collect do |i|
          FactoryGirl.create(:myfile, attachment_updated_at: i.week.ago)
        end
      end

      let!(:recent_myfiles) do
        (1..2).collect do |i|
          FactoryGirl.create(:myfile, attachment_updated_at: i.day.ago)
        end
      end

      it "should return myfiles that where updated until 1 week ago" do
        expect(Myfile.recent).to match_array(recent_myfiles)
      end
    end
  end
end

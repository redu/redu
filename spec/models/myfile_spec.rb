require "spec_helper"

describe Myfile do
  subject { Factory(:myfile, :folder => @folder) }
  before do
    @space = Factory(:space)
    @folder = @space.folders.find_by_name("root")
    @another_folder = @space.folders.create(:name => "another")
  end

  context "when creating a file with existing title in different folders" do
    it "should not remove the previous one" do
      Factory(:myfile, :folder => @another_folder,
              :attachment_file_name => subject.attachment_file_name)
      expect { subject.reload }.to_not raise_error(ActiveRecord::RecordNotFound)
    end
  end


end

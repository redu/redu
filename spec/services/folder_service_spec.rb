require 'spec_helper'

describe FolderService do
  context "creating folder" do
    let(:ability) { mock('Ability') }
    let(:model_attrs) {{ :name => 'New Folder' }}

    subject { FolderService.new(model_attrs) }

    describe "#create" do
      before do
        ability.stub(:authorize!).and_return(true)
      end

      it "should create Folder" do
        expect {
          subject.create
        }.to change(Folder, :count).by(1)
      end

      it "should accept a block" do
        folder = subject.create do |folder|
          folder.user = Factory(:user)
        end

        folder.user.should_not be_nil
      end
    end

    describe "#build" do
      it "should instanciate Folder" do
        model = mock_model('Folder')
        subject.stub(:model).and_return(model)

        model.should_receive(:new).with(model_attrs)
        subject.build
      end

      it "should yield to Myfile.new" do
        expect { |b| subject.build(&b) }.
          to yield_with_args(an_instance_of(Folder))
      end
    end
  end
end

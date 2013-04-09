require 'spec_helper'

describe FolderService do
  context "creating folder" do
    let(:quota) { mock_model('Quota') }
    let(:ability) { mock('Ability') }
    let(:model_attrs) {{ :name => 'New Folder' }}
    let(:params) do
      model_attrs.merge({ :quota => quota, :ability => ability })
    end


    describe "#create" do
      subject { FolderService.new(params) }

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

      it "should delegate to Ability's authorize!" do
        ability.should_receive(:authorize!).
          with(:manage, an_instance_of(Folder))
        subject.create
      end

      it "should raise exception when there's no authorization" do
        ability.stub(:authorize!).
          and_raise(CanCan::AccessDenied.new("Not authorized!"))

        expect {
          subject.create
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe "#build" do
      subject { FolderService.new(params) }

      it "should instanciate Folder" do
        model = mock_model('Folder')
        subject.stub(:model_class).and_return(model)

        model.should_receive(:new).with(model_attrs)
        subject.build
      end

      it "should yield to Folder.new" do
        expect { |b| subject.build(&b) }.
          to yield_with_args(an_instance_of(Folder))
      end
    end

    describe "#destroy" do
      let!(:folder) { Factory(:folder) }
      subject { FolderService.new(params.merge(:model => folder)) }

      before do
        ability.stub(:authorize!).and_return(true)
        quota.stub(:refresh!)
      end

      it "should destroy Folder" do
        expect {
          subject.destroy
        }.to change(Folder, :count).by(-1)
      end

      it "should #refresh! quota" do
        subject.send(:quota).should_receive(:refresh!)
        subject.destroy
      end

      it "should return the folder instance" do
        subject.destroy.should == folder
      end

      it "should delegate to Ability's authorize!" do
        ability.should_receive(:authorize!).with(:manage, folder)
        subject.destroy
      end

      it "should raise exception when there's no authorization" do
        ability.stub(:authorize!).
          and_raise(CanCan::AccessDenied.new("Not authorized!"))

        expect {
          subject.destroy
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end

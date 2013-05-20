# -*- encoding : utf-8 -*-
require 'spec_helper'

describe FolderService do
  context "creating folder" do
    let(:quota) { mock_model('Quota') }
    let(:model_attrs) {{ :name => 'New Folder' }}
    let(:params) do
      model_attrs.merge({ :quota => quota })
    end


    describe "#create" do
      subject { FolderService.new(params) }

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
    end

    describe "#update" do
      let(:folder) { Factory(:folder) }
      let(:user) { Factory(:user) }
      subject { FolderService.new(params.merge(:model => folder)) }
      let(:folder_params) { { :name => "Old" } }

      it "should update folder attributes" do
        expect {
          subject.update(folder_params)
        }.to change { folder.name }.to(folder_params[:name])
      end

      it "should return true if folder is valid" do
          subject.update(folder_params).should be_true
      end

      it "should return false if folder is invalid" do
          subject.update({ :name => "" }).should be_false
      end
    end
  end
end

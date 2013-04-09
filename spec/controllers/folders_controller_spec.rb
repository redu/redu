require 'spec_helper'
require 'authlogic/test_case'

describe FoldersController do
  let(:user) { Factory(:user) }
  let(:space) { Factory(:space, :owner => user) }
  let(:base_params) do
    { :locale => 'pt-BR', :format => :js, :space_id => space.id }
  end

  before do
    login_as user
  end

  context "POST create" do
    let(:params) do
      base_params.merge( :folder => { :name => 'New folder',
                                      :parent_id => space.folders.first.id,
                                      :space_id => space.id })
    end

    it "should assign folder" do
      post :create, params
      assigns[:folder].should == folder
    end

    it "should assing space" do
      post :create, params
      assigns[:space].should == space
    end

    it "should call FolderService.create" do
      FolderService.any_instance.should_receive(:create).and_call_original
      post :create, params
    end

    it "should set folder#user" do
      post :create, params
      assigns[:folder].user.should == user
    end

    it "should set folder#date_modified" do
      post :create, params
      assigns[:folder].date_modified.should_not be_nil
    end
  end

  context "DELETE destroy" do
    let(:folder) { Factory(:folder, :space => space) }
    let(:params) { base_params.merge(:id => folder.to_param) }

    it "should call FolderService.destroy" do
      FolderService.any_instance.should_receive(:destroy).and_call_original
      delete :destroy_folder, params
    end
  end
end

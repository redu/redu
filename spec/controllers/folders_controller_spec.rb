require 'spec_helper'
require 'authlogic/test_case'

describe FoldersController do
  let(:user) { Factory(:user) }
  let(:space) { Factory(:space, :owner => user) }
  let(:params) do
    { :locale => 'pt-BR', :format => :js,
      :space_id => space.id,
      :folder => { :name => 'New folder',
                   :parent_id => space.folders.first.id,
                   :space_id => space.id }}
  end

  before do
    login_as user
  end

  context "POST create" do
    before do
      post :create, params
    end

    it "should assigns folder" do
      assigns[:folder].should_not be_nil
    end

    it "should update user" do
      assigns[:folder].user.should == user
    end

    it "should update date_modified" do
      assigns[:folder].date_modified.should be_within(0.5).of(Time.now)
    end
  end
end

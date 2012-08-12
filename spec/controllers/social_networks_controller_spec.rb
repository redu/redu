require 'spec_helper'
require 'authlogic/test_case'

describe SocialNetworksController do
  include Authlogic::TestCase

  context "POST destroy" do
    before do
      @user = Factory(:user)
      activate_authlogic
      UserSession.create @user
      @social_network = Factory(:social_network, :user => @user)
    end

    it "should load social network" do
      post :destroy, :locale => "pt-BR", :user_id => @social_network.user.login,
             :id => @social_network.id
      assigns[:social_network].should == @social_network
    end

    it "should destroy social network" do
      lambda {
        post :destroy, :locale => "pt-BR", :user_id => @social_network.user.login,
             :id => @social_network.id
      }.should change(SocialNetwork, :count).by(-1)
    end

  end

end

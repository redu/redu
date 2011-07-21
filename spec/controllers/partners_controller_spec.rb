require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe PartnersController do
  before do
    User.maintain_sessions = false
    @user = Factory(:user)
    activate_authlogic
    UserSession.create @user
  end

  context "when viewing a partner" do
    before do
      @partner = Factory(:partner)
      @partner.add_collaborator(@user)

      @associations = 3.times.inject([]) do |acc,i|
        acc << Factory(:partner_environment_association,
                       :partner => @partner)
      end

      @users = 3.times.inject([]) do |acc,i|
        user = Factory(:user)
        @partner.add_collaborator(user)
        acc << user
      end
    end

    it "assigns partner_environment_associations" do
      get :show, :id => @partner.id, :locale => "pt-BR"

      assigns[:partner_environment_associations].should_not be_nil
      assigns[:partner_environment_associations].to_set.should == @associations.to_set
    end

    it "assigns the admins" do
      get :show, :id => @partner.id, :locale => "pt-BR"

      assigns[:users].should_not be_nil
      assigns[:users].to_set.should == @users.push(@user).to_set

    end

    it "assigns partner" do
      get :show, :id => @partner.id, :locale => "pt-BR"

      assigns[:partner].should_not be_nil
      assigns[:partner].should == @partner
    end
  end
end

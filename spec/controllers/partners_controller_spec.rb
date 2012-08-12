require 'spec_helper'
require 'authlogic/test_case'

describe PartnersController do
  include Authlogic::TestCase

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

    it "assigns partner" do
      get :show, :id => @partner.id, :locale => "pt-BR"

      assigns[:partner].should_not be_nil
      assigns[:partner].should == @partner
    end
  end

  context "when contacting a partner" do
    before do
      @partner = Factory(:partner)
      @environment_params = {:name => "Centro de Infromática",
                             :courses_attributes => {"0"=> {:name => "Ciência da Computação", :path => "ciencia-da-computacao" }},
                             :initials => "", :path => "centro-de-infromatica"}

      @contact_params = {:category => "institution",
                         :details => "Mensagem",
                         :environment_name => "Centro de Infromática",
                         :course_name => "Ciência da Computação",
                         :email => "guilhermec@redu.com.br"}

      post :contact, :id => @partner.id, :environment => @environment_params,
        :partner_contact => @contact_params, :locale => "pt-BR", :format => :js
    end

    it "assigns envronment" do
      assigns[:environment].should_not be_nil
    end

    it "creates PartnerContact" do
      assigns[:partner_contact].should_not be_nil
      assigns[:partner_contact].should be_valid
    end
  end

  context "when contacting a partner about migration" do
    before do
      @partner = Factory(:partner)
      @environment = Factory(:environment)

      @contact_params = {:category => "institution",
                         :details => "Mensagem",
                         :migration => true,
                         :billable_url => environment_path(@environment),
                         :email => "guilhermec@redu.com.br"}

      post :contact, :id => @partner.id, :partner_contact => @contact_params,
        :locale => "pt-BR", :format => :js
    end

    it "should not assign environment" do
      assigns[:environment].should be_nil
    end

    it "creates PartnerContact" do
      assigns[:partner_contact].should_not be_nil
      assigns[:partner_contact].should be_valid
    end
  end

  context "when viewing all partners" do
    before do
      @user.role = Role[:admin]
      UserSession.create @user
      get :index, :locale => 'pt-BR'
    end

    it "assigns all partners" do
      assigns[:partners].should_not be_nil
    end
  end
end

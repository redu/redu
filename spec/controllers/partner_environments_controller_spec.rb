require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe PartnerEnvironmentAssociationsController do
  before do
    User.maintain_sessions = false
    @user = Factory(:user)
    activate_authlogic
    UserSession.create @user
  end

  describe "when creating partner environment" do
    before do
      @partner = Factory(:partner)
      @partner.add_collaborator(@user)

      environment = {:name => "Faculdade mauricio de nassau",
          :initials => "FMN",
          :path => "faculdade-mauricio-de-nassau",
          :owner => @user.id }

      @params = {
          :partner_environment_association => { :cnpj => "12.123.123/1234-12",
          :environment_attributes => environment},
          :partner_id => @partner.id,
          :locale => "pt-BR"
      }

    end

    it "assigns a valid PartnerEnvironment" do
      post :create, @params

      assigns[:partner_environment_association].should_not be_nil
      assigns[:partner_environment_association].should be_valid
      should redirect_to partner_environments_path(@partner)
    end

    context "with validation error" do
      before do
        @params[:partner_environment_association].delete(:cnpj)
      end

      it "rerenders new" do
        post :create, @params
        should render_template 'partner_environment_associations/new'
      end
    end
  end

end

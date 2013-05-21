# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'authlogic/test_case'

describe PartnerEnvironmentAssociationsController do
  before do
    @user = FactoryGirl.create(:user)
    login_as @user
  end

  describe "when creating partner environment" do
    before do
      @partner = FactoryGirl.create(:partner)
      @partner.add_collaborator(@user)

      environment = { :name => "Faculdade mauricio de nassau",
          :initials => "FMN",
          :path => "faculdade-mauricio-de-nassau",
          :owner => @user.id,
          :tag_list => "minhas, tags de, teste"}

      @params = {:plan => "licensed_plan-instituicao_superior",
          :partner_environment_association => { :cnpj => "12.123.123/1234-12",
            :address => "Cool Street",
            :company_name => "Cool Inc.",
            :environment_attributes => environment},
          :partner_id => @partner.id,
          :locale => "pt-BR"
      }

    end

    it "assigns a valid PartnerEnvironment" do
      post :create, @params

      assigns[:partner_environment_association].should_not be_nil
      assigns[:partner_environment_association].should be_valid
      should redirect_to controller.partner_path(@partner)
    end

    it "save correctly" do
      expect {
        post :create, @params
      }.to change(Environment, :count).by(1)
    end

    it "should create a plan" do
      expect {
        post :create, @params
      }.to change(Plan, :count).by(1)
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

    context "when there are other collaborators" do
      before do
        @users = 3.times.inject([]) do |acc, el|
          u = FactoryGirl.create(:user)
          @partner.add_collaborator(u)
          acc << u
        end
      end

      it "makes all collaborators environment admin" do
        post :create, @params
        @partner.environments.each do |e|
          @users.to_set.should be_subset(e.administrators.to_set)
        end
      end
    end

    context "when listing partner environments" do
      before do
        @partner = FactoryGirl.create(:partner)
        @partner.add_collaborator(@user)

        3.times.inject([]) do |acc,i|
          environment = FactoryGirl.create(:environment)
          @partner.add_environment(environment, "12.123.123/1234-12",
                                   "Cool Street", "Cool Inc.")
        end
      end

      it "assigns the partner_environment_associations" do
        get :index, :partner_id => @partner.id, :locale => "pt-BR"
        assigns[:partner_environment_associations].should_not be_nil
        assigns[:partner_environment_associations].to_set.should == \
          @partner.partner_environment_associations.to_set
      end
    end
  end
end

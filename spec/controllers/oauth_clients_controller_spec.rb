require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe OauthClientsController do

  before do
    @user = Factory(:partner_user)
    activate_authlogic
    UserSession.create @user

    @params = {
      :client_application => {
        :name => "ReduClient",
        :url => "http://www.redu.com.br"
      }
    }

    @locale = { :locale => "pt-BR" }
  end

  context "GET index" do
    it "assigns all client applications as @client_applications" do
      client_application = @user.client_applications.create @params[:client_application]
      get :index, @locale
      assigns(:client_applications).should eq([client_application])
    end
  end

  describe "GET show" do
    it "assigns the requested client application as @client_application" do
      client_application = @user.client_applications.create @params[:client_application]
      get :show, {:id => client_application.to_param, :locale => "pt-BR"}
      assigns(:client_application).should eq(client_application)
    end
  end

  describe "GET new" do
    it "assigns a new client_application as @client_application" do
      get :new, @locale
      assigns(:client_application).should be_a_new(ClientApplication)
    end
  end

  describe "GET edit" do
    it "assigns the requested client_application as @client_application" do
      client_application = @user.client_applications.create @params[:client_application]
      get :edit, {:id => client_application.to_param, :locale => "pt-BR"}
      assigns(:client_application).should eq(client_application)
    end
  end

end
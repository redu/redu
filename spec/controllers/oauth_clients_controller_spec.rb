require 'spec_helper'
require 'authlogic/test_case'

describe OauthClientsController do
  include Authlogic::TestCase

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

  describe "GET index" do
    it "assigns all client applications as @client_applications" do
      client_application = @user.client_applications.create @params[:client_application]
      get :index, @locale
      assigns(:client_applications).should eq([client_application])
    end

    it "renders the index template" do
      get :index, @locale
      response.should render_template("index")
    end

    it "has a 200 status code" do
      get :index, @locale
      response.code.should eq("200")
    end
  end

  describe "GET show" do
    before do
      @client_application = @user.client_applications.create @params[:client_application]
      get :show, {:id => @client_application.to_param}.merge!(@locale)
    end

    it "assigns the requested client application as @client_application" do
      assigns(:client_application).should eq(@client_application)
    end

    it "renders the show template" do
      response.should render_template("show")
    end

    it "has a 200 status code" do
      response.code.should eq("200")
    end
  end

  describe "GET new" do
    it "assigns a new client_application as @client_application" do
      get :new, @locale
      assigns(:client_application).should be_a_new(ClientApplication)
    end

    it "renders the new template" do
      get :new, @locale
      response.should render_template("new")
    end

    it "has a 200 status code" do
      get :new, @locale
      response.code.should eq("200")
    end
  end

  describe "GET edit" do
    before do
      @client_application = @user.client_applications.create @params[:client_application]
      get :edit, {:id => @client_application.to_param}.merge!(@locale)
    end

    it "assigns the requested client_application as @client_application" do
      assigns(:client_application).should eq(@client_application)
    end

    it "renders the edit template" do
      response.should render_template("edit")
    end

    it "has a 200 status code" do
      response.code.should eq("200")
    end
  end

  describe "POST create" do

    it "creates a new client_application" do
      expect {
        post :create, @params.merge!(@locale)
      }.to change(ClientApplication, :count).by(1)
    end

    context "with valid params" do
      before do
        post :create, @params.merge!(@locale)
      end

      it "assigns a newly created client_application as @client_application" do
        assigns(:client_application).should be_a(ClientApplication)
        assigns(:client_application).should be_persisted
      end

      it "redirects to the created client_application" do
        response.should redirect_to(oauth_client_path(ClientApplication.last))
      end

      it "has a 302 (redirect) status code" do
        response.code.should eq("302")
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved client_application as @client_application" do
        # Trigger the behavior that occurs when invalid params are submitted
        ClientApplication.any_instance.stub(:save).and_return(false)
        post :create, {:client_application => {}, :locale => "pt-BR"}
        assigns(:client_application).should be_a_new(ClientApplication)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ClientApplication.any_instance.stub(:save).and_return(false)
        post :create, {:client_application => {}, :locale => "pt-BR"}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    before do
      @client_application = @user.client_applications.create! @params[:client_application]
      put :update, {:id => @client_application.to_param, :client_application => {'name' => 'UpdatedClient'} }.merge!(@locale)
    end

    context "with valid params" do
      it "updates the requested client application" do
        ClientApplication.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => @client_application.to_param, :client_application => {'these' => 'params'} }.merge!(@locale)
      end

      it "assigns the requested client_application as @client_application" do
        assigns(:client_application).should eq(@client_application)
      end

      it "redirects to the client_application" do
        response.should redirect_to(oauth_client_path(@client_application))
      end

      it "has a 302 (redirect) status code" do
        response.code.should eq("302")
      end
    end

    context "with invalid params" do
      before do
        put :update, {:id => @client_application.to_param, :client_application => {'url' => 'url invalida'} }.merge!(@locale)
      end

      it "reassigns the client_application as @client_application" do
        assigns(:client_application).should eq(@client_application)
      end

      it "re-renders the edit template" do
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before  do
      @client_application = @user.client_applications.create! @params[:client_application]
    end

    it "destroys the requested client_application" do
      expect {
        delete :destroy, {:id => @client_application.to_param}.merge!(@locale)
      }.to change(ClientApplication, :count).by(-1)
    end

    it "redirects to the client_applications list" do
      delete :destroy, {:id => @client_application.to_param}.merge!(@locale)
      response.should redirect_to(oauth_clients_url)
    end
  end

end

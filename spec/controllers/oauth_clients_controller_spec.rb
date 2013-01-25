require 'spec_helper'
require 'authlogic/test_case'

describe OauthClientsController do
  let(:user) { Factory(:user, :role => Role[:admin]) }
  let(:client_application) do
    user.client_applications.create({ :name => "ReduClient",
                                      :url => "http://www,redu.com.br" })
  end
  let(:params) { { :locale => "pt-BR", :user_id => user.to_param } }

  before do
    login_as user
  end

  describe "GET index" do
    it "assigns all client applications as @client_applications" do
      client_application
      get :index, params
      assigns(:client_applications).should eq([client_application])
    end

    it "renders the index template" do
      get :index, params
      response.should render_template("index")
    end

    it "has a 200 status code" do
      get :index, params
      response.code.should eq("200")
    end
  end

  describe "GET show" do
    before do
      get :show, {:id => client_application.to_param}.merge!(params)
    end

    it "assigns the requested client application as @client_application" do
      assigns(:client_application).should eq(client_application)
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
      get :new, params
      assigns(:client_application).should be_a_new(ClientApplication)
    end

    it "renders the new template" do
      get :new, params
      response.should render_template("new")
    end

    it "has a 200 status code" do
      get :new, params
      response.code.should eq("200")
    end
  end

  describe "GET edit" do
    before do
      get :edit, {:id => client_application.to_param}.merge!(params)
    end

    it "assigns the requested client_application as @client_application" do
      assigns(:client_application).should eq(client_application)
    end

    it "renders the edit template" do
      response.should render_template("edit")
    end

    it "has a 200 status code" do
      response.code.should eq("200")
    end
  end

  describe "POST create" do
    let(:entity_params) do
      {
        :client_application => {
          :name => "ReduClient",
          :url => "http://www.redu.com.br"
        }
      }
    end

    it "creates a new client_application" do
      expect {
        post :create, entity_params.merge!(params)
      }.to change(ClientApplication, :count).by(1)
    end

    context "with valid params" do
      before do
        post :create, entity_params.merge!(params)
      end

      it "assigns a newly created client_application as @client_application" do
        assigns(:client_application).should be_a(ClientApplication)
        assigns(:client_application).should be_persisted
      end

      it "redirects to the created client_application" do
        response.should redirect_to(user_oauth_client_path(user, ClientApplication.last))
      end

      it "has a 302 (redirect) status code" do
        response.code.should eq("302")
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved client_application as @client_application" do
        # Trigger the behavior that occurs when invalid params are submitted
        ClientApplication.any_instance.stub(:save).and_return(false)
        post :create, {:client_application => {} }.merge!(params)
        assigns(:client_application).should be_a_new(ClientApplication)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ClientApplication.any_instance.stub(:save).and_return(false)
        post :create, {:client_application => {} }.merge!(params)
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    before do
      put :update, {:id => client_application.to_param,
                    :client_application => {'name' => 'UpdatedClient'} }.
                    merge!(params)
    end

    context "with valid params" do
      it "updates the requested client application" do
        ClientApplication.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => client_application.to_param,
                      :client_application => {'these' => 'params'} }.
                      merge!(params)
      end

      it "assigns the requested client_application as @client_application" do
        assigns(:client_application).should eq(client_application)
      end

      it "redirects to the client_application" do
        response.should redirect_to(user_oauth_client_path(user,
                                                           client_application))
      end

      it "has a 302 (redirect) status code" do
        response.code.should eq("302")
      end
    end

    context "with invalid params" do
      before do
        put :update, {:id => client_application.to_param,
                      :client_application => {'url' => 'url invalida'} }.
                      merge!(params)
      end

      it "reassigns the client_application as @client_application" do
        assigns(:client_application).should eq(client_application)
      end

      it "re-renders the edit template" do
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested client_application" do
      client_application
      expect {
        delete :destroy, {:id => client_application.to_param}.merge!(params)
      }.to change(ClientApplication, :count).by(-1)
    end

    it "redirects to the client_applications list" do
      delete :destroy, {:id => client_application.to_param}.merge!(params)
      response.should redirect_to(user_oauth_clients_url(user))
    end
  end
end

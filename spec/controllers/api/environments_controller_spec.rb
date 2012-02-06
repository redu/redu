require 'spec_helper'

describe Api::EnvironmentsController do
  subject { Factory(:complete_environment) }

  def parse(json)
    ActiveSupport::JSON.decode(json)
  end

  context "get /api/environments/id" do
    it "should return status 200" do
      get :show, :id => subject.id, :format => :json, :locale => 'pt-BR'

      response.code.should == '200'
    end

    it "should represent the environment" do
      get :show, :id => subject.id, :format => :json, :locale => 'pt-BR'

      %w(name description created_at links path initials).each do |attr|
        parse(response.body).should have_key attr
      end
    end

    it "should return status 404 when doesnt exist" do
      get :show, :id => 91209, :format => :json, :locale => 'pt-BR'

      response.code.should == '404'
    end
  end

  context "post /api/environments/id" do
    xit "should create an environment" do
      controller.stub!(:current_user).and_return Factory(:user)

      params = { :name => 'New environment' }
      post :create, :environment => params, :format => :json, :locale => 'pt-BR'
    end
  end

  context "get /api/environments" do
    it "should return status 200" do
      get :index, :format => :json, :locale => 'pt-BR'

      response.status.should == 200
    end

    it "should return all environments" do
      2.times { Factory(:environment) }
      get :index, :format => :json, :locale => 'pt-BR'

      parse(response.body).should be_kind_of Array
      parse(response.body).length.should == 2
    end
  end

  context "delete /api/environments/id" do
    it "should return status 200" do
      delete :destroy, :id => subject.id, :format => :json, :locale => 'pt-BR'

      response.status.should == 200
    end

    it "should return status 404 when doesnt exist" do
      delete :destroy, :id => 33232, :format => :json, :locale => 'pt-BR'

      response.status.should == 404
    end
  end
end

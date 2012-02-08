require 'spec_helper'

describe "Api::EnvironmentsController" do
  subject { Factory(:complete_environment) }

  def parse(json)
    ActiveSupport::JSON.decode(json)
  end

  def href_to(rel, representation)
    representation.fetch('links', []).detect { |link| link['rel'] == rel }.
      fetch('href', nil)
  end

  context "the document returned" do
    it "should have the correct keys" do
      get "/api/environments/#{subject.id}", :format => 'json'

      %w(name description created_at links path initials id).each do |attr|
        parse(response.body).should have_key attr
      end
    end

    it "should embed a link to self and courses" do
      get "/api/environments/#{subject.id}", :format => 'json'
      links = parse(response.body).fetch('links', {})

      %w(courses self).each do |prop|
        links.collect { |l| l.fetch 'rel' }.should include prop
      end
    end
  end

  context "get /api/environments/id" do
    it "should return status 200" do
      get "/api/environments/#{subject.id}", :format => 'json'

      response.code.should == '200'
    end


    it "should return status 404 when doesnt exist" do
      get "/api/environments/0912092", :format => 'json'

      response.code.should == '404'
    end
  end

  context "post /api/environments" do
    before do
      @user = Factory(:user)
      Api::EnvironmentsController.any_instance.stub(:current_user).
        and_return @user

      @params = { :name => 'New environment', :path => 'environment-path',
                  :initials => 'NE' }
    end

    it "should create an environment" do
      post "/api/environments", :environment => @params, :format => 'json'
      representation = parse(response.body)
      get href_to('self', representation), :format => 'json'

      response.code.should == '200'
    end

    it "should return status 201 when successful" do
      post "/api/environments", :environment => @params, :format => 'json'

      response.status.should == 201
    end

    it "should return the environment representation" do
      post "/api/environments", :environment => @params, :format => 'json'

      parse(response.body).should have_key('name')
      parse(response.body).fetch('name').should == @params[:name]
    end

    it "should return 422 (unproccessable entity) when invalid" do
      @params = { :name => 'Invalid entity' }
      post "/api/environments", :environment => @params, :format => 'json'

      response.status.should == 422
    end
  end

  context "put /api/environment/id" do
    before do
      @user = Factory(:user)
      EnvironmentsController.any_instance.stub(:current_user).and_return @user

      @environment = Factory(:complete_environment)
    end

    it "should return status 200" do
      updated_params = { :name => 'New name' }

      put "/api/environments/#{@environment.id}", :environment => updated_params,
        :format => 'json'

      response.status.should == 200
    end

    it "should return 422 when invalid" do
      updated_params = { :name => 'Big name Big name Big name Big name Big name' }

      put "/api/environments/#{@environment.id}", :environment => updated_params,
        :format => 'json'

      response.status.should == 422
    end
  end

  context "get /api/environments" do
    it "should return status 200" do
      get "/api/environments", :format => 'json'

      response.status.should == 200
    end

    it "should return all environments" do
      2.times { Factory(:environment) }
      get '/api/environments', :format => 'json'

      parse(response.body).should be_kind_of Array
      parse(response.body).length.should == 2
    end
  end

  context "delete /api/environments/id" do
    it "should return status 200" do
      delete "/api/environments/#{subject.id}", :format => 'json'

      response.status.should == 200
    end

    it "should return status 404 when doesnt exist" do
      delete "/api/environments/20202020", :format => 'json'

      response.status.should == 404
    end
  end
end

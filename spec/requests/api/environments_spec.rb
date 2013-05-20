# -*- encoding : utf-8 -*-
require 'api_spec_helper'

describe "Environments API" do
  subject { Factory(:complete_environment) }
  before do
    @application, @current_user, @token = generate_token(subject.owner)
  end

  context "the document returned" do
    it "should have the correct keys" do
      get "/api/environments/#{subject.id}", :oauth_token => @token,
        :format => 'json'

      %w(name description created_at updated_at links path initials id
         courses_count).each do |attr|
        parse(response.body).should have_key attr
      end
    end

    it "should embed a link to self, courses and user" do
      get "/api/environments/#{subject.id}", :oauth_token => @token,
        :format => 'json'
      links = parse(response.body).fetch('links', {})

      %w(courses self user).each do |prop|
        links.collect { |l| l.fetch 'rel' }.should include prop
      end
    end

    it "shold be return code 200 passing both ID and path" do
      get "/api/environments/#{subject.path}", :oauth_token => @token,
        :format => 'json'

      response.status.should == 200
    end
  end

  context "get /api/environments/id" do
    it "should return status 200" do
      get "/api/environments/#{subject.id}", :oauth_token => @token,
        :format => 'json'

      response.code.should == '200'
    end


    it "should return status 404 when doesnt exist" do
      get "/api/environments/0912092", :oauth_token => @token,
        :format => 'json'

      response.code.should == '404'
    end
  end

  context "post /api/environments" do
    before do
      @user = Factory(:user)
      @params = { :name => 'New environment', :path => 'environment-path',
                  :initials => 'NE' }
    end

    it "should create an environment" do
      post "/api/environments", :environment => @params,
        :oauth_token => @token, :format => 'json'
      representation = parse(response.body)
      get href_to('self', representation), :oauth_token => @token,
        :format => 'json'

      response.code.should == '200'
    end

    it "should return status 201 when successful" do
      post "/api/environments", :environment => @params, :oauth_token => @token,
        :format => 'json'

      response.status.should == 201
    end

    it "should return the environment representation" do
      post "/api/environments", :environment => @params, :oauth_token => @token,
        :format => 'json'

      parse(response.body).should have_key('name')
      parse(response.body).fetch('name').should == @params[:name]
    end

    it "should return 422 (unproccessable entity) when invalid" do
      @params = { :name => 'Invalid entity' }
      post "/api/environments", :environment => @params, :oauth_token => @token,
        :format => 'json'

      response.status.should == 422
    end
  end

  context "put /api/environment/id" do
    it "should return status 204" do
      updated_params = { :name => 'New name' }

      put "/api/environments/#{subject.id}", :environment => updated_params,
        :oauth_token => @token, :format => 'json'

      response.status.should == 204
    end

    it "should return 422 when invalid" do
      updated_params = { :name => 'Big name Big name Big name Big name Big name' }

      put "/api/environments/#{subject.id}", :environment => updated_params,
        :oauth_token => @token, :format => 'json'

      response.status.should == 422
    end
  end

  context "get /api/environments" do
    it "should return status 200" do
      get "/api/environments", :oauth_token => @token,
        :format => 'json'

      response.status.should == 200
    end

    it "should return current user environments" do
      2.times { Factory(:environment, :owner => @current_user) }
      get '/api/environments', :oauth_token => @token,
        :format => 'json'

      parse(response.body).should be_kind_of Array
      parse(response.body).length.should == 3
    end
  end

  context "delete /api/environments/id" do
    it "should return status 204" do
      delete "/api/environments/#{subject.id}", :oauth_token => @token,
        :format => 'json'

      response.status.should == 204
    end

    it "should return status 404 when doesnt exist" do
      delete "/api/environments/20202020", :oauth_token => @token,
        :format => 'json'

      response.status.should == 404
    end
  end
end

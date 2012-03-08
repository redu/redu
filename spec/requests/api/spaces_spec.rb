require 'api_spec_helper'

describe "Api::SpacesController" do
  before do
    @application, @current_user, @token = generate_token
    @course = Factory(:complete_course)
    @space = @course.spaces.first
  end

  context "the document returned" do
    before do
      get "/api/spaces/#{@space.id}", :oauth_token => @token,
         :format => 'json'
    end

    it "should have the correct keys" do
      %w(name description created_at links).each do |attr|
        parse(response.body).should have_key attr
      end
    end

    it "should hold a relationship to self, course, environment and users"  do
      links = parse(response.body)['links']
      links.collect! { |l| l.fetch('rel') }

      links.should include 'self'
      links.should include 'course'
      links.should include 'environment'
      links.should include 'users'
    end
  end

  context "get /spaces/:id" do
    it "should return status 200" do
      get "/api/spaces/#{@space.id}", :oauth_token => @token,
         :format => 'json'
      response.code.should == "200"
    end

    it "should return 404 when doesnt exists" do
      get '/api/spaces/1212121', :oauth_token => @token,
         :format => 'json'
      response.code.should == "404"
    end
  end

  context "get /course/:id/spaces" do
    it "should return code 200" do
      get "/api/courses/#{@course.id}/spaces", :oauth_token => @token,
         :format => 'json'
      response.code.should == "200"
    end

    it "should represent the spaces" do
      get "/api/courses/#{@course.id}/spaces", :oauth_token => @token,
         :format => 'json'

      parse(response.body).should be_kind_of Array
      parse(response.body).first['name'].should == @space.name
    end
  end

  context "post /course/:id/spaces" do
    it "should return code 201 (created)" do
      space = { :name => 'My new space' }
      post "/api/courses/#{@course.id}/spaces", :space => space,
        :oauth_token => @token, :format => 'json'

      response.code.should == '201'
    end

    it "should return the entity" do
      space = { :name => 'My new space' }
      post "/api/courses/#{@course.id}/spaces", :oauth_token => @token,
        :space => space, :format => 'json'

      parse(response.body).should have_key('name')
    end

    it "should return code 422 (unproccessable entity) when not valid" do
      space = { :name => 'Big Space Name Big Space Name Big Space Name Big Space Name ' }
      post "/api/courses/#{@course.id}/spaces", :oauth_token => @token,
        :space => space, :format => 'json'

      response.code.should == "422"
    end

    it "should return the error explanation" do
      space = { :name => 'Big Space Name Big Space Name Big Space Name Big Space Name ' }
      post "/api/courses/#{@course.id}/spaces", :oauth_token => @token,
        :space => space, :format => 'json'

      parse(response.body).should have_key 'name'
    end
  end

  context "put /spaces/:id" do
    it "should return code 201" do
      space = { :name => 'new_space_name' }
      put "/api/spaces/#{@space.id}", :space => space, :oauth_token => @token,
        :format => 'json'

      response.code.should == "200"
    end

    it "should return code 422 (unproccessable entity) when not valid" do
      space = { :name => 'Big Space Name Big Space Name Big Space Name Big Space Name ' }
      put "/api/spaces/#{@space.id}", :space => space, :oauth_token => @token,
        :format => 'json'

      response.code.should == "422"
    end

    it "should return the error explanation" do
      space = { :name => 'Big Space Name Big Space Name Big Space Name Big Space Name ' }
      put "/api/spaces/#{@space.id}", :space => space, :oauth_token => @token,
        :format => 'json'

      parse(response.body).should have_key 'name'
    end
  end

  context "delete /spaces/:id" do
    it "should return status 200" do
      delete "/api/spaces/#{@space.id}", :oauth_token => @token,
        :format => 'json'

      response.status.should == 200
    end

    it "should return 404 when doesnt exist" do
      delete "/api/spaces/09202", :oauth_token => @token,
        :format => 'json'

      response.status.should == 404
    end
  end
end


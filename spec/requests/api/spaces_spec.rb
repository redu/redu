require 'spec_helper'

describe "Api::SpacesController" do
  subject do
    course = Factory(:complete_course)
    course.spaces.first
  end

  def parse(json)
    ActiveSupport::JSON.decode(json)
  end

  context "the document returned" do
    before do
      get "/api/spaces/#{subject.id}", :format => 'json'
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
      get "/api/spaces/#{subject.id}", :format => 'json'
      response.code.should == "200"
    end

    it "should return 404 when doesnt exists" do
      get '/api/spaces/1212121', :format => 'json'
      response.code.should == "404"
    end
  end

  context "get /course/:id/spaces" do
    it "should return code 200" do
      get "/api/courses/#{subject.course.id}/spaces", :format => 'json'
      response.code.should == "200"
    end

    it "should represent the spaces" do
      get "/api/courses/#{subject.course.id}/spaces", :format => 'json'

      parse(response.body).should be_kind_of Array
      parse(response.body).first['name'].should == subject.name
    end
  end

  context "post /course/:id/spaces" do
    before do
      Api::SpacesController.any_instance.stub(:current_user).
        and_return Factory(:user)
    end

    it "should return code 201 (created)" do
      space = { :name => 'My new space' }
      post "/api/courses/#{subject.course.id}/spaces",
        :space => space, :format => 'json'

      response.code.should == '201'
    end

    it "should return the entity" do
      space = { :name => 'My new space' }
      post "/api/courses/#{subject.course.id}/spaces",
        :space => space, :format => 'json'

      parse(response.body).should have_key('name')
    end

    it "should return code 422 (unproccessable entity) when not valid" do
      space = { :name => 'Big Space Name Big Space Name Big Space Name Big Space Name ' }
      post "/api/courses/#{subject.course.id}/spaces",
        :space => space, :format => 'json'

      response.code.should == "422"
    end

    it "should return the error explanation" do
      space = { :name => 'Big Space Name Big Space Name Big Space Name Big Space Name ' }
      post "/api/courses/#{subject.course.id}/spaces",
        :space => space, :format => 'json'

      parse(response.body).should have_key 'name'
    end
  end

  context "put /spaces/:id" do
    it "should return code 201" do
      space = { :name => 'new_space_name' }
      put "/api/spaces/#{subject.id}", :space => space, :format => 'json'

      response.code.should == "200"
    end

    it "should return code 422 (unproccessable entity) when not valid" do
      space = { :name => 'Big Space Name Big Space Name Big Space Name Big Space Name ' }
      put "/api/spaces/#{subject.id}", :space => space, :format => 'json'

      response.code.should == "422"
    end

    it "should return the error explanation" do
      space = { :name => 'Big Space Name Big Space Name Big Space Name Big Space Name ' }
      put "/api/spaces/#{subject.id}", :space => space, :format => 'json'

      parse(response.body).should have_key 'name'
    end
  end

  context "delete /spaces/:id" do
    it "should return status 200" do
      delete "/api/spaces/#{subject.id}", :format => 'json'

      response.status.should == 200
    end

    it "should return 404 when doesnt exist" do
      delete "/api/spaces/09202", :format => 'json'

      response.status.should == 404
    end

  end
end


require 'spec_helper'

describe "Api::CoursesController" do
  subject do
    environment = Factory(:complete_environment)
    environment.courses.first
  end

  def parse(json)
    ActiveSupport::JSON.decode(json)
  end

  context "the document returned" do
    before do
      get "/api/courses/#{subject.id}", :format => 'json'
    end

    it "should have the correct keys" do
      %w(name description created_at links workload id path).each do |attr|
        parse(response.body).should have_key attr
      end
    end

    it "should hold a relationship to self and spaces"  do
      links = parse(response.body)['links']
      links.collect! { |l| l.fetch('rel') }

      links.should include 'self'
      links.should include 'spaces'
    end
  end

  context "get /courses/:id" do
    it "should return status 200" do
      get "/api/courses/#{subject.id}", :format => 'json'
      response.code.should == "200"
    end

    it "should return 404 when doesnt exists" do
      get '/api/courses/1212121', :format => 'json'
      response.code.should == "404"
    end
  end

  context "get /environment/:id/courses" do
    it "should return code 200" do
      get "/api/environments/#{subject.environment.id}/courses", :format => 'json'
      response.code.should == "200"
    end

    it "should represent the courses" do
      get "/api/environments/#{subject.environment.id}/courses", :format => 'json'

      parse(response.body).should be_kind_of Array
      parse(response.body).first['name'].should == subject.name
    end
  end

  context "post /environment/:id/courses" do
    before do
      Api::CoursesController.any_instance.stub(:current_user).
        and_return Factory(:user)
    end

    it "should return code 201 (created)" do
      course = { :name => 'My new course', :path => 'my_new_course' }
      post "/api/environments/#{subject.environment.id}/courses",
        :course => course, :format => 'json'

      response.code.should == '201'
    end

    it "should return the entity" do
      course = { :name => 'My new course', :path => 'my_new_course' }
      post "/api/environments/#{subject.environment.id}/courses",
        :course => course, :format => 'json'

      parse(response.body).should have_key('name')
    end

    it "should return code 422 (unproccessable entity) when not valid" do
      course = { :path => 'my_new_course' }
      post "/api/environments/#{subject.environment.id}/courses",
        :course => course, :format => 'json'

      response.code.should == "422"
    end

    it "should return the error explanation" do
      course = { :path => 'my_new_course' }
      post "/api/environments/#{subject.environment.id}/courses",
        :course => course, :format => 'json'

      parse(response.body).should have_key 'name'
    end
  end

  context "put /courses/:id" do
    it "should return code 201" do
      course = { :name => 'new_course_name' }
      put "/api/courses/#{subject.id}", :course => course, :format => 'json'

      response.code.should == "200"
    end

    it "should return code 422 (unproccessable entity) when not valid" do
      course = { :path => 'my_new_cou//rse' } # path inválido
      put "/api/courses/#{subject.id}", :course => course, :format => 'json'

      response.code.should == "422"
    end

    it "should return the error explanation" do
      course = { :path => 'my_new_cou//rse' } # path inválido
      put "/api/courses/#{subject.id}", :course => course, :format => 'json'

      parse(response.body).should have_key 'path'
    end
  end

  context "delete /courses/:id" do
    it "should return status 200" do
      delete "/api/courses/#{subject.id}", :format => 'json'

      response.status.should == 200
    end

    it "should return 404 when doesnt exist" do
      delete "/api/courses/09202", :format => 'json'

      response.status.should == 404
    end

  end
end

require 'api_spec_helper'

describe Api::CoursesController do
  subject do
    environment = Factory(:complete_environment)
    environment.courses.first
  end
  before do
    @application, @current_user, @token = generate_token(subject.owner)
  end

  context "the document returned" do
    before do
      get "/api/courses/#{subject.id}", :oauth_token => @token,
        :format => 'json'
    end

    it "should have the correct keys" do
      %w(name description created_at updated_at links workload id path).each do |attr|
        parse(response.body).should have_key attr
      end
    end

    it "should hold a relationship to self, spaces, environment and enrollments"  do
      links = parse(response.body)['links']
      links.collect! { |l| l.fetch('rel') }

      %w( self spaces environment enrollments ).each do |link|
        links.should include link
      end
    end

    it "should return valid relationships" do
      parse(response.body)['links'].each do |rel|
        get rel['href'], :format => 'json', :oauth_token => @token
        response.code.should == "200"
      end
    end

    it "shold be return code 200 passing both ID and path" do
      get "/api/courses/#{subject.path}", :oauth_token => @token,
        :format => 'json'

      response.status.should == 200
    end
  end

  context "get /courses/:id" do
    it "should return status 200" do
      get "/api/courses/#{subject.id}", :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return 404 when doesnt exists" do
      get '/api/courses/1212121',  :oauth_token => @token,
        :format => 'json'
      response.code.should == "404"
    end
  end

  context "get /environment/:id/courses" do
    it "should return code 200" do
      get "/api/environments/#{subject.environment.id}/courses",
        :oauth_token => @token, :format => 'json'
      response.code.should == "200"
    end

    it "should represent the courses" do
      get "/api/environments/#{subject.environment.id}/courses",
        :oauth_token => @token, :format => 'json'

      parse(response.body).should be_kind_of Array
      parse(response.body).first['name'].should == subject.name
    end
  end

  context "post /environment/:id/courses" do
    it "should return code 201 (created)" do
      course = { :name => 'My new course', :path => 'my_new_course' }
      post "/api/environments/#{subject.environment.id}/courses",
        :course => course, :oauth_token => @token, :format => 'json'

      response.code.should == '201'
    end

    it "should return the entity" do
      course = { :name => 'My new course', :path => 'my_new_course' }
      post "/api/environments/#{subject.environment.id}/courses",
        :course => course, :oauth_token => @token, :format => 'json'

      parse(response.body).should have_key('name')
    end

    it "should return code 422 (unproccessable entity) when not valid" do
      course = { :path => 'my_new_course' }
      post "/api/environments/#{subject.environment.id}/courses",
        :course => course, :oauth_token => @token, :format => 'json'

      response.code.should == "422"
    end

    it "should return the error explanation when there are errors" do
      course = { :path => 'my_new_course' }
      post "/api/environments/#{subject.environment.id}/courses",
        :course => course, :oauth_token => @token, :format => 'json'

      parse(response.body).should have_key 'name'
    end

    it "should not create the course without an environment" do
      course = { :name => 'My new course', :path => 'my_new_course' }
      post "/api/environments/1212121/courses",
        :course => course, :oauth_token => @token, :format => 'json'

      response.code.should == '404'
    end
  end

  context "put /courses/:id" do
    it "should return code 201" do
      course = { :name => 'new_course_name' }
      put "/api/courses/#{subject.id}", :course => course,
        :oauth_token => @token, :format => 'json'

      response.code.should == "200"
    end

    it "should return code 422 (unproccessable entity) when not valid" do
      course = { :path => 'my_new_cou//rse' } # path inválido
      put "/api/courses/#{subject.id}", :course => course,
        :oauth_token => @token, :format => 'json'

      response.code.should == "422"
    end

    it "should return the error explanation" do
      course = { :path => 'my_new_cou//rse' } # path inválido
      put "/api/courses/#{subject.id}", :course => course,
        :oauth_token => @token, :format => 'json'

      parse(response.body).should have_key 'path'
    end

  end

  context "delete /courses/:id" do
    it "should return status 204" do
      delete "/api/courses/#{subject.id}", :oauth_token => @token,
        :format => 'json'

      response.status.should == 204
    end

    it "should return 404 when doesnt exist" do
      delete "/api/courses/09202", :oauth_token => @token,
        :format => 'json'

      response.status.should == 404
    end

  end
end

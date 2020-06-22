# -*- encoding : utf-8 -*-
require 'api_spec_helper'

describe "Spaces API" do
  before do
    @environment = FactoryBot.create(:complete_environment)
    @course = @environment.courses.first
    @space = @course.spaces.first
    @application, @current_user, @token = generate_token(@course.owner)
  end

  context "the document returned" do
    before do
      get "/api/spaces/#{@space.id}", oauth_token: @token,
         format: 'json'
    end

    it "should have the correct keys" do
      %w(name description created_at updated_at links id).each do |attr|
        parse(response.body).should have_key attr
      end
    end

    %w(self course environment users statuses timeline folders canvas).
      each do |link|
        it "should hold a relationship to #{link}"  do
          href_to(link, parse(response.body)).should_not be_blank
        end
    end
  end

  context "get /spaces/:id" do
    it "should return status 200" do
      get "/api/spaces/#{@space.id}", oauth_token: @token,
         format: 'json'
      response.code.should == "200"
    end

    it "should return 404 when doesnt exists" do
      get '/api/spaces/1212121', oauth_token: @token,
         format: 'json'
      response.code.should == "404"
    end
  end

  context "get /course/:id/spaces" do
    before do
      @teacher = FactoryBot.create(:user)
      @course.join(@teacher, Role[:teacher])
    end

    it "should return code 200" do
      get "/api/courses/#{@course.id}/spaces", oauth_token: @token,
         format: 'json'
      response.code.should == "200"
    end

    it "should represent the spaces" do
      get "/api/courses/#{@course.id}/spaces", oauth_token: @token,
         format: 'json'

      parse(response.body).should be_kind_of Array
      parse(response.body).first['name'].should == @space.name
    end
  end

  context "get /users/:id/spaces" do
    before do
      @new_env = FactoryBot.create(:complete_environment)
      @new_course = @new_env.courses.first
      @new_space = @new_course.spaces.first
      @user = @space.users.first
      @new_course.join(@user, Role[:teacher])
    end

    it "should return code 200" do
      get "/api/users/#{@user.id}/spaces", oauth_token: @token,
        format: 'json'

      response.code == '200'
    end

    it "should return the user spaces" do
      get "/api/users/#{@user.id}/spaces", oauth_token: @token,
        format: 'json'

      parse(response.body).length.should == 2
    end

    it "should filter by teacher role" do
      get "/api/users/#{@user.id}/spaces", role: 'teacher',
        oauth_token: @token, format: 'json'

      parse(response.body).length.should == 1
    end

    it "should filter by administrator role" do
      get "/api/users/#{@user.id}/spaces", role: 'environment_admin',
        oauth_token: @token, format: 'json'

      parse(response.body).length.should == 1
    end

    it "should filter by course and role" do
      # /api/users/1/spaces?role=teacher&course_id=2
      get "/api/users/#{@user.id}/spaces", role: 'teacher',
        course: @new_course.id, oauth_token: @token,
        format: 'json'

      parse(response.body).first['id'].should == @new_space.id
    end

    it "should filter by course" do
      get "/api/users/#{@user.id}/spaces", course: @new_course.id,
        oauth_token: @token, format: 'json'

      parse(response.body).first['id'].should == @new_space.id
    end
  end

  context "post /course/:id/spaces" do
    it "should return code 201 (created)" do
      space = { name: 'My new space' }
      post "/api/courses/#{@course.id}/spaces", space: space,
        oauth_token: @token, format: 'json'

      response.code.should == '201'
    end

    it "should return the entity" do
      space = { name: 'My new space' }
      post "/api/courses/#{@course.id}/spaces", oauth_token: @token,
        space: space, format: 'json'

      parse(response.body).should have_key('name')
    end

    it "should return code 422 (unproccessable entity) when not valid" do
      space = { name: 'Big Space Name Big Space Name Big Space Name Big Space Name ' }
      post "/api/courses/#{@course.id}/spaces", oauth_token: @token,
        space: space, format: 'json'

      response.code.should == "422"
    end

    it "should return the error explanation" do
      space = { name: 'Big Space Name Big Space Name Big Space Name Big Space Name ' }
      post "/api/courses/#{@course.id}/spaces", oauth_token: @token,
        space: space, format: 'json'

      parse(response.body).should have_key 'name'
    end
  end

  context "put /spaces/:id" do
    it "should return code 204" do
      space = { name: 'new_space_name' }
      put "/api/spaces/#{@space.id}", space: space, oauth_token: @token,
        format: 'json'

      response.code.should == "204"
    end

    it "should return code 422 (unproccessable entity) when not valid" do
      space = { name: 'Big Space Name Big Space Name Big Space Name Big Space Name ' }
      put "/api/spaces/#{@space.id}", space: space, oauth_token: @token,
        format: 'json'

      response.code.should == "422"
    end

    it "should return the error explanation" do
      space = { name: 'Big Space Name Big Space Name Big Space Name Big Space Name ' }
      put "/api/spaces/#{@space.id}", space: space, oauth_token: @token,
        format: 'json'

      parse(response.body).should have_key 'name'
    end
  end

  context "delete /spaces/:id" do
    it "should return status 204" do
      delete "/api/spaces/#{@space.id}", oauth_token: @token,
        format: 'json'

      response.status.should == 204
    end

    it "should return 404 when doesnt exist" do
      delete "/api/spaces/09202", oauth_token: @token,
        format: 'json'

      response.status.should == 404
    end
  end
end


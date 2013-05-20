# -*- encoding : utf-8 -*-
require "api_spec_helper"

describe Api::CourseEnrollmentsController do
  let(:environment) { Factory(:complete_environment) }
  let(:course) { environment.courses.first }
  let(:user) { environment.owner }
  let(:token) { _, _, token = generate_token(environment.owner); token }
  let(:params) do
    { :oauth_token => token, :format => 'json' }
  end

  context "the document returned" do
    before do
      @enrollment = Factory(:user_course_invitation, :course => course)
      @enrollment.invite!
    end

    it "should return code 200 (ok)" do
      get "/api/enrollments/#{@enrollment.id}", params
      response.code.should == "200"
    end

    it "should have state redu_invited" do
      get "/api/enrollments/#{@enrollment.id}", params
      parse(response.body).fetch('state', '').should == 'redu_invited'
    end
  end

  context "when enrolling the user which isnt registered yet" do
    before do
      @enrollment = { :email => 'abc@def.gh' }
      post "/api/courses/#{course.id}/enrollments",
        params.merge({ :enrollment => @enrollment })
      @entity = parse(response.body)
    end

    it "should return status 201 (created)" do
      response.code.should == "201"
    end


    %w(state id email token links created_at updated_at role).each do |key|
      it "should have #{key} key" do
        @entity.should have_key(key)
      end
    end

    it "should link to itself, course and environment" do
      links = @entity["links"]
      links.collect! { |link| link.fetch('rel') } # somente os tipos de rel

      %w(self course environment).each do |rel|
        links.should include(rel)
      end
    end

    it "should link correctly to itself" do
      link = @entity["links"].detect { |link| link['rel'] == 'self' } # self

      get link['href'], params
      response.code.should == '200'
    end

    it "should default to redu_invited" do
      @entity.fetch('state', '').should == 'redu_invited'
    end
  end

  context "when enrolling the user which IS registered" do
    before do
      @user = Factory(:user)
      @enrollment = { :email => @user.email }
      post "/api/courses/#{course.id}/enrollments",
        params.merge({:enrollment => @enrollment})
      @entity = parse(response.body)
    end

    it "should return 201 (created)" do
      response.code.should == "201"
    end

    it "should have state, id, created_at and links keys" do
      %w(state id links created_at).each do |key|
        @entity.should have_key(key)
      end
    end

    it "should link to itself, course, user and environment" do
      links = @entity["links"]
      links.collect! { |link| link.fetch('rel') } # somente os tipos de rel

      %w(self course environment user).each do |rel|
        links.should include(rel)
      end
    end

    it "should default to invited" do
      @entity.fetch('state', '').should == 'invited'
    end
  end

  context "when listing enrollments" do
    before do
      @enrollment1 = { :email => 'abc@def.gh' }
      @user = Factory(:user)
      @enrollment2 = { :email => @user.email }
      post "/api/courses/#{course.id}/enrollments",
        params.merge({:enrollment => @enrollment1})
      post "/api/courses/#{course.id}/enrollments",
        params.merge({:enrollment => @enrollment2})
    end

    it "should return code 200 (ok)" do
      get "/api/courses/#{course.id}/enrollments", params

      response.code.should == '200'
    end

    it "should list any type of enrollment" do
      get "/api/courses/#{course.id}/enrollments", params

      parse(response.body).length.should == 3
    end
  end

  context "when listing user's enrollments" do
    before do
      # Associando @current_user a um novo curso
      @environment2 = Factory(:complete_environment)
      @environment2.courses.first.join(user)
    end

    it "should return status 200 (ok)" do
      get "/api/users/#{user.id}/enrollments", params
      response.code.should == '200'
    end

    it "should return the correct enrollments" do
      get "/api/users/#{user.id}/enrollments", params
      parse(response.body).count.should == 2
    end

    it "should be able to filter by one courses_ids" do
      filter = { :courses_ids => @environment2.courses.map(&:id) }
      get "/api/users/#{user.id}/enrollments", params.merge(filter)

      expected = user.course_enrollments.
        where(:course_id => filter[:courses_ids]).value_of(:id)
      parse(response.body).map { |c| c["id"] }.should == expected
    end

    it "should be able to filter by multiple courses_ids" do
      filter = { :courses_ids => @environment2.courses.map(&:id) }
      filter[:courses_ids] = environment.courses.first.id

      get "/api/users/#{user.id}/enrollments", params.merge(filter)

      expected = user.course_enrollments.
        where(:course_id => filter[:courses_ids]).value_of(:id)
      parse(response.body).map { |c| c["id"] }.should == expected
    end
  end

  context "when DELETE enrollment" do
    before do
      @external_user = Factory(:user)
      course.join(@external_user)

      get "/api/enrollments/#{@external_user.get_association_with(course).id}",
        params
      @href = parse(response.body)['links'].detect { |link| link['rel'] == 'self' }
      @href = @href.fetch('href','')
    end

    it "should return status 204 (ok)" do
      delete @href, params
      response.code.should == '204'
    end

    it "should remove the enrollment" do
      delete @href, params
      get @href, params
      response.code.should == '404'
    end

    context "when the user isnt registered" do
      it "should remove the enrollment" do
        post "/api/courses/#{course.id}/enrollments",
          params.merge({:enrollment => { :email => 'abc@def.gh' }})

        id = parse(response.body)['id']
        delete "/api/enrollments/#{id}", params
        get "/api/enrollments/#{id}", params
        response.code.should == '404'
      end
    end
  end
end

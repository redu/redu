require "api_spec_helper"

describe Api::CourseEnrollmentsController do
  before do
    @environment = Factory(:complete_environment)
    @course = @environment.courses.first
  end

  context "the document returned" do
    before do
      @enrollment = Factory(:user_course_invitation, :course => @course)
      @enrollment.invite!
    end

    it "should return code 200 (ok)" do
      get "/api/enrollments/#{@enrollment.id}", :format => 'json'
      response.code.should == "200"
    end

    it "should have state redu_invited" do
      get "/api/enrollments/#{@enrollment.id}", :format => 'json'
      parse(response.body).fetch('state', '').should == 'redu_invited'
    end
  end

  context "when enrolling the user which isnt registered yet" do
    before do
      @enrollment = { :email => 'abc@def.gh' }
      post "/api/courses/#{@course.id}/enrollments", :enrollment => @enrollment,
        :format => 'json'
      @entity = parse(response.body)
    end

    it "should return status 201 (created)" do
      response.code.should == "201"
    end

    it "should have state, id, email, token, created_at and links keys" do
      %w(state id email token links created_at).each do |key|
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

      get link['href'], :format => 'json'
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
      post "/api/courses/#{@course.id}/enrollments", :enrollment => @enrollment,
        :format => 'json'
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
      post "/api/courses/#{@course.id}/enrollments", :enrollment => @enrollment1,
        :format => 'json'
      post "/api/courses/#{@course.id}/enrollments", :enrollment => @enrollment2,
        :format => 'json'
    end

    it "should return code 200 (ok)" do
      get "/api/courses/#{@course.id}/enrollments", :format => 'json'

      response.code.should == '200'
    end

    it "should list any type of enrollment" do
      get "/api/courses/#{@course.id}/enrollments", :format => 'json'

      parse(response.body).length.should == 3
    end
  end
end

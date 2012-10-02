require "api_spec_helper"

describe Api::CourseEnrollmentsController do
  before do
    @environment = Factory(:complete_environment)
    @application, @current_user, @token = generate_token(@environment.owner)
    @course = @environment.courses.first
  end

  context "the document returned" do
    before do
      @enrollment = Factory(:user_course_invitation, :course => @course)
      @enrollment.invite!
    end

    it "should return code 200 (ok)" do
      get "/api/enrollments/#{@enrollment.id}", :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should have state redu_invited" do
      get "/api/enrollments/#{@enrollment.id}", :oauth_token => @token,
         :format => 'json'
      parse(response.body).fetch('state', '').should == 'redu_invited'
    end
  end

  context "when enrolling the user which isnt registered yet" do
    before do
      @enrollment = { :email => 'abc@def.gh' }
      post "/api/courses/#{@course.id}/enrollments", :enrollment => @enrollment,
        :oauth_token => @token, :format => 'json'
      @entity = parse(response.body)
    end

    it "should return status 201 (created)" do
      response.code.should == "201"
    end

    it "should have state, id, email, token, created_at and links keys" do
      %w(state id email token links created_at updated_at).each do |key|
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

      get link['href'], :oauth_token => @token, :format => 'json'
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
        :oauth_token => @token, :format => 'json'
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
        :oauth_token => @token, :format => 'json'
      post "/api/courses/#{@course.id}/enrollments", :enrollment => @enrollment2,
        :oauth_token => @token, :format => 'json'
    end

    it "should return code 200 (ok)" do
      get "/api/courses/#{@course.id}/enrollments",:oauth_token => @token,
        :format => 'json'

      response.code.should == '200'
    end

    it "should list any type of enrollment" do
      get "/api/courses/#{@course.id}/enrollments",:oauth_token => @token,
        :format => 'json'

      parse(response.body).length.should == 3
    end
  end

  context "when listing user's enrollments" do
    before do
      # Associando @current_user a um novo curso
      @environment2 = Factory(:complete_environment)
      @course.join(@current_user)
      get "/api/users/#{@current_user.id}/enrollments", :oauth_token => @token,
        :format => 'json'
    end

    it "should return status 200 (ok)" do
      response.code.should == '200'
    end

    it "should return the correct enrollments" do
      get "/api/users/#{@current_user.id}/enrollments", :format => 'json'
      parse(response.body).count.should == 2
    end
  end

  context "when DELETE enrollment" do
    before do
      @external_user = Factory(:user)
      @course.join(@external_user)

      get "/api/enrollments/#{@external_user.get_association_with(@course).id}",
        :format => 'json', :oauth_token => @token
      @href = parse(response.body)['links'].detect { |link| link['rel'] == 'self' }
      @href = @href.fetch('href','')
    end

    it "should return status 200 (ok)" do
      delete @href, :format => 'json', :oauth_token => @token
      response.code.should == '200'
    end

    it "should remove the enrollment" do
      delete @href, :format => 'json', :oauth_token => @token
      get @href, :format => 'json', :oauth_token => @token
      response.code.should == '404'
    end

    context "when the user isnt registered" do
      it "should remove the enrollment" do
        post "/api/courses/#{@course.id}/enrollments",
          :enrollment => { :email => 'abc@def.gh' }, :oauth_token => @token,
          :format => 'json'

        id = parse(response.body)['id']
        delete "/api/enrollments/#{id}", :oauth_token => @token, :format => 'json'
        get "/api/enrollments/#{id}", :oauth_token => @token, :format => 'json'
        response.code.should == '404'
      end
    end
  end
end

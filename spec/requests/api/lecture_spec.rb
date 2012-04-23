require "api_spec_helper"

describe "Lectures" do
  before do
    @application, @current_user, @token = generate_token
  end

  context "when GET api/lectures/lecture_id" do
    before do
      @lecture = Factory(:lecture)
    end

    it "should return 200" do
      @env = Factory(:complete_environment, :owner => @current_user)
      @course = @env.courses.first
      @space = @course.spaces.first
      @subject = Factory(:subject, :owner => @current_user, :space => @space)
      @lecture = Factory(:lecture, :subject => @subject, :owner => @current_user)

      get "/api/lectures/#{@lecture.id}", :oauth_token => @token, 
        :format => 'json'
      response.code.should == "200"
    end

  end

end

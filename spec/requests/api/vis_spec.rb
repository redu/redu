require 'api_spec_helper'

describe "Vis Api" do
  before do
    @environment = Factory(:complete_environment)
    @course = @environment.courses.first
    @space = @course.spaces.first
    @application, @current_user, @token = generate_token(@course.owner)
  end

  context "get /vis/spaces/:id/lecture_participation" do
    it "should return status 200" do
      @params = {
        :lectures => ["2", "3"],
        :date_start => "2012-02-10",
        :date_end => "2012-02-11",
        :oauth_token => @token,
        :format => 'json'
      }

      get "/api/vis/spaces/#{@space.id}/lecture_participation", @params

      debugger
      response.code.should == "200"
    end

    it "should return 404 when doesnt exists" do
      get "/api/vis/spaces/1212121/lecture_participation",
        :oauth_token => @token,
        :format => 'json'
      response.code.should == "404"
    end
  end
end

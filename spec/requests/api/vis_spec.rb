require 'api_spec_helper'

describe "Vis Api" do
  context "get /vis/spaces/:space_id/lecture_participation" do
    before do
      @environment = Factory(:complete_environment)
      @course = @environment.courses.first
      @space = @course.spaces.first

      @application, @current_user, @token = generate_token(@course.owner)
    end

    it "should return status 200" do
      @params = {
        :lectures => ["2", "3"],
        :date_start => "2012-02-10",
        :date_end => "2012-02-11",
        :oauth_token => @token,
        :format => 'json'
      }

      get "/api/vis/spaces/#{@space.id}/lecture_participation", @params

      response.code.should == "200"
    end

    it "should return 404 when doesnt exists" do
      get "/api/vis/spaces/1212121/lecture_participation",
        :oauth_token => @token,
        :format => 'json'

      response.code.should == "404"
    end
  end

  context "get" do
    before do
      @application, @current_user, @token = generate_token

      @environment = Factory(:complete_environment, :owner => @current_user)
      @space = @environment.courses.first.spaces.first

      @subject = Subject.create(:title => "Test Subject 1",
                                :description => "Test Subject Description",
                                :space => @space)
      # precisa atualizar manualmente para criar um módulo vazio
      @subject.update_attribute(:finalized, true)

      @params = {:oauth_token => @token, :format => "json"}
    end

    context "/vis/subjects/:subject_id/subject_activities" do
      it "should return status 200" do
        @params = {
          :oauth_token => @token,
          :format => 'json'
        }

        get "/api/vis/subjects/#{@subject.id}/subject_activities", @params

        response.code.should == "200"
      end

      it "should return 404 when doesnt exists" do
        get "/api/vis/subjects/121212/subject_activities",
          :oauth_token => @token,
          :format => 'json'

        response.code.should == "404"
      end
    end

    context "/vis/subjects/:subject_id/subject_activities_d3" do
      it "should return status 200" do
        @params = {
          :oauth_token => @token,
          :format => 'json'
        }

        get "/api/vis/subjects/#{@subject.id}/subject_activities_d3", @params

        response.code.should == "200"
      end

      it "should return 404 when doesnt exists" do
        get "/api/vis/subjects/121212/subject_activities_d3",
          :oauth_token => @token,
          :format => 'json'

        response.code.should == "404"
      end
    end
  end
end

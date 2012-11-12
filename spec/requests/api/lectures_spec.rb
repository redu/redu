require 'api_spec_helper'

describe "Lectures API" do
  before do
    environment = Factory(:complete_environment)
    course = environment.courses.first
    space = course.spaces.first
    @subject = Factory(:subject, :owner => course.owner,
                       :space => space, :finalized => true)
    Factory(:lecture, :subject => @subject, :owner => course.owner)

    @application, @current_user, @token = generate_token(course.owner)
  end
  context "post /subjects/:subject_id/lectures" do
    context "when creating canvas" do
      before do
        @client_app = Factory(:client_application, :user => @current_user)
        @params = { :oauth_token => @token, :format => 'json' }
      end

      let(:correct_params) do
        @params[:lecture] = {
          :name => "My Goku Lecture",
          :type => "Canvas",
          :lectureable => {
            :client_application_id => @client_app.id
          }
        }
      end

      it "should return code 201(created)" do
        correct_params
        post "api/subjects/#{@subject.id}/lectures", @params
        response.code.should == '201'
      end

      it "should return the entity" do
        correct_params
        post "api/subjects/#{@subject.id}/lectures", @params
        parse(response.body).should have_key('name')
      end

      let(:inc_params) do
        @params[:lecture] = {
          :name => ""
        }
      end

      it "should return code 422 when not valid" do
        inc_params
        post "api/subjects/#{@subject.id}/lectures", @params
        response.code.should == '422'
      end

      it "should return the error explanation" do
        inc_params
        post "api/subjects/#{@subject.id}/lectures", @params
        %w(name lectureable).each do |attr|
          parse(response.body).should have_key attr
        end
      end
    end
  end
end

require 'api_spec_helper'

describe "Media API" do
  let(:current_user) { Factory(:user) }
  let(:environment) { Factory(:complete_environment, :owner => current_user) }
  let(:course) { environment.courses.first }
  let(:space) { course.spaces.first }
  let(:sub) { Factory(:subject, :owner => current_user, :space => space) }
  let(:token) { _, _, token = generate_token(current_user); token }
  let(:base_params) do
    { :oauth_token => token, :format => :json }
  end

  context "GET /api/lectures/:id" do
    context "when external media (ie. Youtube)" do
      subject do
        Factory(:lecture, :lectureable => Factory(:seminar_youtube), :subject => sub)
      end
      before do
        get "/api/lectures/#{subject.id}", base_params
      end

      it_should_behave_like "a lecture"

      it "should have video/x-youtube as mimetype" do
        parse(response.body)["mimetype"].should == "video/x-youtube"
      end

      it "should have a link to Youtube" do
        href_to('raw', parse(response.body)).
          should_not be_blank
      end

      it "should have the Media type" do
        parse(response.body)["type"].should == "Media"
      end
    end

    context "when uploaded media" do
      subject do
        Factory(:lecture, :lectureable => Factory(:seminar_upload), :subject => sub)
      end
      before do
        get "/api/lectures/#{subject.id}", base_params
      end

      it_should_behave_like "a lecture"

      it "should have the correct mimetype" do
        parse(response.body)["mimetype"].
          should == subject.lectureable.original_content_type
      end

      it "should have a link to the raw file" do
        href_to('raw', parse(response.body)).
          should_not be_blank
      end
    end
  end
end

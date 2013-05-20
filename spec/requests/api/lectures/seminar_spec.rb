# -*- encoding : utf-8 -*-
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

  context "POST /api/subjects/:id/lectures (uploaded video)" do
    let(:mimetype) { 'video/mpeg' }
    let(:url) { "/api/subjects/#{sub.id}/lectures"  }
    let(:lecture_params) do
      path = "#{RSpec.configuration.fixture_path}/api/video_example.avi"

      { :lecture => \
        { :name => 'Lorem', :type => 'Media',
          :media => fixture_file_upload(path, mimetype) }
      }.merge(base_params)
    end

    it_should_behave_like "a lecture created"

    it "should have raw link" do
      post url, lecture_params
      lecture = parse(response.body)
      href_to("raw", lecture).should_not be_blank
    end

    context "with validation error" do
      let(:seminar_params) do
        { :lecture => { :name => 'Lorem', :type => 'Media', :media => nil } }.
          merge(base_params)
      end

      it "should return 422 HTTP code" do
        post "/api/subjects/#{sub.id}/lectures", seminar_params
        response.code.should == "422"
      end

      it "should return the validation error" do
        post "/api/subjects/#{sub.id}/lectures", seminar_params
        response.body.should =~ /lectureable\.original_file_name/
      end
    end
  end

  context "POST /api/subjects/:id/lectures (youtube video)" do
    let(:file) { "http://www.youtube.com/watch?v=h--OXNNCEz0" }
    let(:lecture_params) do
      { :lecture => { :name => 'Lorem', :type => 'Media', :media => file } }.
        merge(base_params)
    end
    let(:url) { "/api/subjects/#{sub.id}/lectures"  }

    it_should_behave_like "a lecture created" do
      let(:mimetype) { 'video/x-youtube' }
    end

    it "should return the link to the raw video" do
      post "/api/subjects/#{sub.id}/lectures", lecture_params
      lecture = parse(response.body)
      href_to("raw", lecture).should == file
    end
  end

end

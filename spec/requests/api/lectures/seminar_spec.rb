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
    let(:file) do
      fixture_file_upload("/api/video_example.avi", "video/mpeg")
    end
    let(:seminar_params) do
      { :lecture => { :name => 'Lorem', :type => 'Media', :media => file } }.
        merge(base_params)
    end

    it "should return 201 HTTP code" do
      post "/api/subjects/#{sub.id}/lectures", seminar_params
      response.code.should == "201"
    end

    it "should return the correct type" do
      post "/api/subjects/#{sub.id}/lectures", seminar_params
      parse(response.body)['type'].should == 'Media'
    end

    it "should return the link to the raw video" do
      post "/api/subjects/#{sub.id}/lectures", seminar_params
      lecture = parse(response.body)
      href_to("raw", lecture).should_not be_blank
    end

    it "should have the correct mimetype" do
      post "/api/subjects/#{sub.id}/lectures", seminar_params
      parse(response.body)["mimetype"].should == "video/mpeg"
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
        response.body.should =~ /não pode ser deixado em branco/
      end
    end
  end

  context "POST /api/subjects/:id/lectures (youtube video)" do
    let(:file) do
      "http://www.youtube.com/watch?v=h--OXNNCEz0"
    end
    let(:seminar_params) do
      { :lecture => { :name => 'Lorem', :type => 'Media', :media => file } }.
        merge(base_params)
    end

    it "should return 201 HTTP code" do
      post "/api/subjects/#{sub.id}/lectures", seminar_params
      response.code.should == "201"
    end

    it "should return the correct type" do
      post "/api/subjects/#{sub.id}/lectures", seminar_params
      parse(response.body)['type'].should == 'Media'
    end

    it "should return the link to the raw video" do
      post "/api/subjects/#{sub.id}/lectures", seminar_params
      lecture = parse(response.body)
      href_to("raw", lecture).should == file
    end

    it "should have the correct mimetype" do
      post "/api/subjects/#{sub.id}/lectures", seminar_params
      parse(response.body)["mimetype"].should == "video/x-youtube"
    end
  end

end

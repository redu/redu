require 'api_spec_helper'

describe 'Seminars' do
  before do
    @application, @current_user, @token = generate_token
  end
  let(:params) do
    { :oauth_token => @token, :format  => 'json' }
  end
  let(:environment) do
    Factory(:complete_environment, :owner => @current_user)
  end
  let(:subj) do
    course = environment.courses.first
    space = course.spaces.first
    Factory(:subject, :space => space, :owner => space.owner)
  end

  context "GET /api/lectures/:id (youtube)" do
    let(:youtube) do
      Factory(:lecture, :owner => subj.owner,
              :subject => subj, :lectureable => Factory(:seminar_youtube))
    end

    it "should return HTTP code 200" do
      get "/api/lectures/#{youtube.id}", params
      response.code.should == '200'
    end

    it "should have the correct propeties" do
      get "/api/lectures/#{youtube.id}", params
      entity = parse(response.body)['lectureable']

      %w(state url).each do |attr|
        entity.should have_key(attr)
      end
    end

    it "should return a valid youtube link" do
      get "/api/lectures/#{youtube.id}", params
      url = parse(response.body)['lectureable']['url']
      url.should =~ /^http:\/\/youtube.com\/watch\?v=.*/
    end
  end

  context "GET /api/lectures/:id (upload)" do
    let(:video) do
      s = Factory.build(:seminar_upload)
      File.open("#{Rails.root}/spec/support/documents/video.MPG", 'r') do |f|
        s.media = f
      end
      s.save

      Factory(:lecture, :owner => subj.owner,
              :subject => subj, :lectureable => s )
    end

    it "should return HTTP code 200" do
      get "/api/lectures/#{video.id}", params
      response.code.should == '200'
    end

    it "should have the correct propeties" do
      get "/api/lectures/#{video.id}", params
      entity = parse(response.body)['lectureable']

      %w(state url).each do |attr|
        entity.should have_key(attr)
      end
    end

    it "should return a valid link" do
      get "/api/lectures/#{video.id}", params
      url = parse(response.body)['lectureable']['url']
      url.should =~ /video\.MPG/
    end
  end
end

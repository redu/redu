require 'api_spec_helper'

describe 'Pages' do
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
  let(:page) do
    Factory(:lecture, :owner => subj.owner, :subject => subj)
  end

  context "GET /api/lectures/:id" do
    it "should return HTTP code 200" do
      get "/api/lectures/#{page.id}", params
      response.code.should == '200'
    end

    it "should have the correct properties" do
      get "/api/lectures/#{page.id}", params
      entity = parse(response.body)

      %w(id type name created_at view_count position rating lectureable).
        each { |attr| entity.should have_key(attr) }
    end

    it "should have the correct lectureable properties" do
      get "/api/lectures/#{page.id}", params
      entity = parse(response.body)['lectureable']
      entity.should have_key('body')
    end

    it "should have the correct links" do
      2.times.collect do
        Factory(:lecture, :owner => subj.owner, :subject => subj)
      end
      page.move_up!

      get "/api/lectures/#{page.id}", params
      entity = parse(response.body)

      %w(self next_lecture previous_lecture).each do |link|
        get href_to(link, entity), params
        response.code.should == '200'
      end
    end

    it "should return HTTP code 404 when doesnt exist" do
      get '/api/lectures/1221', params
      response.code.should == '404'
    end
  end
end

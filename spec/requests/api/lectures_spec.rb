require 'api_spec_helper'

describe 'Lectures' do
  before do
    @application, @current_user, @token = generate_token
  end
  let(:params) do
    { :oauth_token => @token, :format  => 'json' }
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

  context "pointers" do
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

    it "should navigate through the links" do
      # Criando 3 aulas
      page
      2.times.collect do
        Factory(:lecture, :owner => subj.owner, :subject => subj)
      end

      # Primeira aula
      get "/api/lectures/#{subj.lectures.first.id}", params
      first = parse(response.body)
      response.code.should == '200'

      # Segunda aula
      get href_to('next_lecture', first), params
      second = parse(response.body)
      response.code.should == '200'
      href_to('previous_lecture', second).should == href_to('self', first)

      # Última aula
      get href_to('next_lecture', second), params
      third = parse(response.body)
      response.code.should == '200'
      href_to('previous_lecture', third).should == href_to('self', second)
      third['next_lecture'].should be_nil
    end
  end

  context "when GET /api/lectures/:id" do
    it "should return HTTP code 200" do
      get "/api/lectures/#{page.id}", params
      response.code.should == '200'
    end

    it "should have the correct properties" do
      get "/api/lectures/#{page.id}", params
      entity = parse(response.body)

      %w(id type name created_at view_count position rating lectureable position).
        each { |attr| entity.should have_key(attr) }
    end
  end

  context "when GET /api/subjects/:subect_id/lectures" do
    it "should return HTTP code 200"
    it "should return HTTP code 404 when subject doesnt exist"
    it "should filter by lectureable type (page)"
    it "should filter by lectureable type (seminar)"
    it "should filter by lectureable type (document)"
    it "should filter by lectureable type (exercise)"
  end
end

# -*- encoding : utf-8 -*-
require 'api_spec_helper'

describe "Page API" do
  let(:environment) { FactoryBot.create(:complete_environment) }
  let(:course) { environment.courses.first }
  let(:space) { course.spaces.first }
  let(:subj) { FactoryBot.create(:subject, :owner => course.owner,
                       :space => space, :finalized => true) }
  let(:token) { _, _, token = generate_token(course.owner); token}
  let(:base_params) do
    { :oauth_token => token, :format => 'json' }
  end

  context "when GET /lectures/:id" do
    subject do
      FactoryBot.create(:lecture, :lectureable => FactoryBot.create(:page),
              :subject => subj, :owner => subj.owner)
    end

    before do
      get "/api/lectures/#{subject.id}", base_params
    end

    it_should_behave_like "a lecture"

    %w(content raw).each do |attr|
      it "should have #{attr} property" do
        parse(response.body).should have_key attr
      end
    end

    it "should have the right content" do
      parse(response.body).fetch("content").should == subject.lectureable.body
    end
  end

  context "when POST /api/subjects/:id/lectures (Page)" do
    it_should_behave_like "a lecture created" do
      let(:mimetype) { 'text/html' }
      let(:url) { "/api/subjects/#{subj.id}/lectures"  }
      let(:lecture_params) do
        { :lecture => \
          { :name => 'Lorem', :type => 'Page', :content => "<html></html>" }
        }.merge(base_params)
      end
    end

    context "with validation errors" do
      let(:lecture_params) do
        { :lecture => { :name => 'Lorem', :type => 'Page', :content => nil } }.
          merge(base_params)
      end
      before do
        post "/api/subjects/#{subj.id}/lectures", lecture_params
      end

      it "should return 422 HTTP code" do
        response.code.should == "422"
      end

      it "should return the validation error" do
        response.body.should =~ /lectureable\.body/
      end
    end
  end
end

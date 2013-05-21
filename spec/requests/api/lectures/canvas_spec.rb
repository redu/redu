# -*- encoding : utf-8 -*-
require 'api_spec_helper'

describe "Canvas API" do
  let(:environment) { FactoryGirl.create(:complete_environment) }
  let(:course) { environment.courses.first }
  let(:space) { course.spaces.first }
  let(:subj) { FactoryGirl.create(:subject, :owner => course.owner,
                          :space => space, :finalized => true) }
  let(:token) { _, _, token = generate_token(course.owner); token }
  let(:base_params) { { :oauth_token => token, :format => 'json' } }

  context "when POST /subjects/:subject_id/lectures" do
    context "when the params is correct" do
      it_should_behave_like "a lecture created" do
        let(:mimetype) { 'application/x-canvas' }
        let(:url) { "/api/subjects/#{subj.id}/lectures"  }
        let(:lecture_params) do
          { :lecture => \
            { :name => 'Lorem', :type => 'Canvas',
              :current_url => "http://foo.bar.com" }
          }.merge(base_params)
        end
      end
    end

    context "when the params aren't correct" do
      let(:params) { base_params.merge({ :lecture => { :name => "" } }) }

      it "should return code 422 when not valid" do
        post "api/subjects/#{subj.id}/lectures", params
        response.code.should == '422'
      end

      it "should return the error explanation" do
        post "api/subjects/#{subj.id}/lectures", params
        parse(response.body).should have_key "name"
      end
    end
  end

    context "when creating canvas with URL" do
      context "when the params are correct" do
        let(:params) do
          base_params.merge({:lecture => {
            :name => "My Goku Lecture",
            :type => "Canvas",
            :current_url => "http://google.com.br",
          }})
        end

        it "should return code 201 (created)" do
          post "api/subjects/#{subj.id}/lectures", params
          response.code.should == '201'
        end

        it "should return the entity" do
          post "api/subjects/#{subj.id}/lectures", params
          parse(response.body)["current_url"].should ==
              params[:lecture][:current_url]
        end
      end

      context "when the params are incorrect" do
        let(:params) do
          base_params.merge({:lecture => {
            :name => "My Goku Lecture",
            :type => "Canvas",
            :current_url => "google.com.br",
          }})
        end

        it "should return code 422" do
          post "api/subjects/#{subj.id}/lectures", params
          response.code.should == '422'
        end

        it "should return the error explanation" do
          post "api/subjects/#{subj.id}/lectures", params
          parse(response.body).values.flatten.should include "não é uma URL"
        end
      end
    end

  context "when GET /lectures/:id" do
    subject do
      FactoryGirl.create(:lecture, :lectureable => FactoryGirl.create(:canvas, :container => space),
              :subject => subj, :owner => subj.owner)
    end

    before do
      get "/api/lectures/#{subject.id}", base_params
    end

    it_should_behave_like "a lecture"
    it_should_behave_like "a canvas"

    it "should have property mimetype" do
      parse(response.body).should have_key 'mimetype'
    end
  end
end

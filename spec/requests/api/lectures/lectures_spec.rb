# -*- encoding : utf-8 -*-
require 'api_spec_helper'

describe "Lecture API" do
  let(:environment) { FactoryBot.create(:complete_environment) }
  let(:course) { environment.courses.first }
  let(:space) { course.spaces.first }
  let(:subj) { space.subjects.first }
  let(:token) { _, _, token = generate_token(subject.owner); token }
  let(:params) { { :oauth_token => token, :format => 'json' } }

  context "when DELETE /api/lectures/:id"  do
    subject { subj.lectures.first }
    let(:lecture_href) { "/api/lectures/#{subject.id}" }

    before do
      delete lecture_href, params
    end

    it "should return status 204" do
      response.code.should == "204"
    end

    it "should delete the lecture" do
      get lecture_href, params
      response.code.should == "404"
    end
  end
end

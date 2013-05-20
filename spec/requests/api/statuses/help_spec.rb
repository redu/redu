# -*- encoding : utf-8 -*-
require "api_spec_helper"

describe "Help" do
  let(:current_user) { Factory(:user) }
  let(:token) { _, _, token = generate_token(current_user); token }
  let(:space) do
    environment = Factory(:complete_environment, :owner => current_user)
    environment.courses.first.spaces.first
  end
  let(:lecture) do
    s = Factory(:subject, :owner => space.owner, :space => space)
    c = Factory(:canvas, :user => s.owner)
    Factory(:lecture, :owner => s.owner, :subject => s,
            :lectureable => c)
  end
  let(:help) do
    Factory(:help, :user => lecture.owner, :statusable => lecture)
  end
  let(:params) { { :oauth_token => token, :format => 'json'} }

  context "when GET /api/statuses/:id (type help)" do
    before do
      get "/api/statuses/#{help.id}", params
      @entity = parse(response.body)
    end

    it "should have type, text, created_at answers_count" do
      %w(type text created_at answers_count).each do |attr|
        @entity.should have_key attr
      end
    end

    it "should have a link statusable, self, user and answers" do
      %w(statusable self user answers).each do |attr|
        get href_to(attr, @entity), params
        response.code.should == "200"
      end
    end

    it_should_behave_like "embeds user" do
      let(:embeder) { help }
      let(:user) { embeder.user }
      let(:entity) { @entity }
    end

    it_should_behave_like 'having breadcrumbs', "Lecture" do
      let(:get_params) { params }
      let(:status) { help }
    end
  end
end

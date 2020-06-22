# -*- encoding : utf-8 -*-
require 'api_spec_helper'

describe "Media API" do
  let(:current_user) { FactoryBot.create(:user) }
  let(:environment) { FactoryBot.create(:complete_environment, owner: current_user) }
  let(:course) { environment.courses.first }
  let(:space) { course.spaces.first }
  let(:sub) { FactoryBot.create(:subject, owner: current_user, space: space) }
  let(:token) { _, _, token = generate_token(current_user); token }
  let(:params) do
    { oauth_token: token, format: :json }
  end
  let(:exercise) { FactoryBot.create(:complete_exercise) }

  subject do
    FactoryBot.create(:lecture, lectureable: exercise, subject: sub)
  end

  before do
    get "/api/lectures/#{subject.id}", params
  end

  it_should_behave_like "a lecture"
end

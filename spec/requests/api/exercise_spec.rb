require 'api_spec_helper'

describe "Media API" do
  let(:current_user) { Factory(:user) }
  let(:environment) { Factory(:complete_environment, :owner => current_user) }
  let(:course) { environment.courses.first }
  let(:space) { course.spaces.first }
  let(:sub) { Factory(:subject, :owner => current_user, :space => space) }
  let(:token) { _, _, token = generate_token(current_user); token }
  let(:params) do
    { :oauth_token => token, :format => :json }
  end
  let(:exercise) { Factory.create(:complete_exercise) }

  subject do
    Factory.create(:lecture, :lectureable => exercise, :subject => sub)
  end

  before do
    get "/api/lectures/#{subject.id}", params
  end

  it_should_behave_like "a lecture"
end

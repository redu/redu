require 'api_spec_helper'

describe "Page API" do
  let(:environment) { Factory(:complete_environment) }
  let(:course) { environment.courses.first }
  let(:space) { course.spaces.first }
  let(:subj) { Factory(:subject, :owner => course.owner,
                       :space => space, :finalized => true) }
  let(:token) { _, _, token = generate_token(course.owner); token}
  let(:base_params) do
    { :oauth_token => token, :format => 'json' }
  end

  context "when GET /lectures/:id" do
    subject do
      Factory(:lecture, :lectureable => Factory(:page),
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
  end
end

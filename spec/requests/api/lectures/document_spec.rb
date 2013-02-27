require 'api_spec_helper'

describe "Documents API" do
  let(:environment) { Factory(:complete_environment) }
  let(:course) { environment.courses.first }
  let(:space) { course.spaces.first }
  let(:subj) { Factory(:subject, :owner => course.owner,
                          :space => space, :finalized => true) }
  let(:token) { _, _, token = generate_token(course.owner); token }
  let(:params) { { :oauth_token => token, :format => 'json' } }

  context "when GET /lectures/:id" do
     subject do
       mock_scribd_api
       Factory(:lecture, :lectureable => Factory(:document),
               :subject => subj, :owner => subj.owner)
     end

     before do
       get "/api/lectures/#{subject.id}", params
     end

     it_should_behave_like "a lecture"

     it "should have property mimetype" do
       parse(response.body).should have_key "mimetype"
     end

     %w(raw scribd).each do |link|
       it "should have the link #{link}" do
         href_to(link, parse(response.body)).should_not be_blank
       end
     end
   end
end

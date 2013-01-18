require 'api_spec_helper'

describe "Documents API" do
  before do
    environment = Factory(:complete_environment)
    course = environment.courses.first
    space = course.spaces.first
    @subject = Factory(:subject, :owner => course.owner,
                       :space => space, :finalized => true)
    Factory(:lecture, :subject => @subject, :owner => course.owner)

    @application, @current_user, @token = generate_token(course.owner)
  end
  let(:base_params) do
    { :oauth_token => @token, :format => 'json' }
  end

  context "when GET /lectures/:id" do
     let(:lecture) do
       Factory(:lecture, :lectureable => Factory(:document),
               :subject => @subject, :owner => @subject.owner)
     end

     before do
       mock_scribd_api
       get "/api/lectures/#{lecture.id}", base_params
     end

     it_should_behave_like "lecture"

     it "lectureable should have property mimetype" do
       lectureable = parse(response.body)["lectureable"]
       lectureable.should have_key "mimetype"
     end

     %w(raw scribd).each do |link|
       it "lectureable should have the link #{link}" do
         lectureable = parse(response.body)["lectureable"]
         links = lectureable['links'].collect { |l| l.fetch "rel" }
         links.should include link
       end
     end
   end
end

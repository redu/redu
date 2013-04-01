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
    context "with attachment with document format" do
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

  context "when POST /api/subjects/:id/lectures" do
    it_should_behave_like "a lecture created" do
      let(:mimetype) { "application/vnd.ms-powerpoint" }
      let(:url) { "/api/subjects/#{subj.id}/lectures"  }
      let(:lecture_params) do
        { :lecture => \
          { :name => 'Lorem', :type => 'Document',
            :media => fixture_file_upload("/api/document_example.pptx", mimetype) }
        }.merge(params)
      end
    end

    context "with validation error" do
      let(:lecture_params) do
        { :lecture => { :name => 'Lorem', :type => 'Document', :media => nil } }.
          merge(params)
      end

      it "should return 422 HTTP code" do
        post "/api/subjects/#{subj.id}/lectures", lecture_params
        response.code.should == "422"
      end

      it "should return the validation error" do
        post "/api/subjects/#{subj.id}/lectures", lecture_params
        response.body.should =~ /lectureable\.attachment/
      end
    end
  end
end

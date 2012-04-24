require 'api_spec_helper'

describe 'Documents' do
  before do
    @application, @current_user, @token = generate_token
  end
  let(:params) do
    { :oauth_token => @token, :format  => 'json' }
  end
  let(:environment) do
    Factory(:complete_environment, :owner => @current_user)
  end
  let(:subj) do
    course = environment.courses.first
    space = course.spaces.first
    Factory(:subject, :space => space, :owner => space.owner)
  end
  let(:document) do
    doc = Factory.build(:document)
    document_path = "#{Rails.root}/spec/support/documents/document_test.pdf"
    File.open(document_path, 'r') { |f| doc.attachment = f }
    doc.save

    Factory(:lecture, :owner => subj.owner, :subject => subj, :lectureable => doc)
  end

  context "GET /api/lectures/:id" do
    before do
      mock_scribd_api
      get "/api/lectures/#{document.id}", params
    end

    it "should return HTTP status 200" do
      response.code.should == '200'
    end

    it "should have the correct properties" do
      parse(response.body)['lectureable'].should have_key('url')
    end

    it "should have a link to the document" do
      parse(response.body)['lectureable']['url'] =~ /document_test\.pdf/
    end
  end

end

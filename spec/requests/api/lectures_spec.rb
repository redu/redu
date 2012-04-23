require 'api_spec_helper'

describe 'Lectures' do
  before do
    @application, @current_user, @token = generate_token
  end
  let(:params) do
    { :oauth_token => @token, :format  => 'json' }
  end

  context "when Document" do
    it "should have the correct properties"
    it "should return HTTP code 404 when doesnt exist"
    it "should return the original document"
    it "should return the embed code"
  end

  context "when Exercise" do
  end

  context "when Seminar" do
  end


  context "when GET /api/subjects/:subect_id/lectures" do
    it "should return HTTP code 200"
    it "should return HTTP code 404 when subject doesnt exist"
    it "should filter by lectureable type (page)"
    it "should filter by lectureable type (seminar)"
    it "should filter by lectureable type (document)"
    it "should filter by lectureable type (exercise)"
  end
end

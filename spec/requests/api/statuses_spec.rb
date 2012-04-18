require "api_spec_helper"

describe "Statuses" do
  before do
    @application, @current_user, @token = generate_token
    @activity = Factory(:activity, :user => @current_user)
  end

  it "should return status 200 (ok)" do
    get "/api/statuses/#{@activity.id}", :oauth_token => @token, :format => 'json'

    response.code.should == '200'
  end

  it "should have id, text, created_at, links, action and type" do
    get "/api/statuses/#{@activity.id}", :oauth_token => @token, :format => 'json'

    %w(id text created_at links action type).each do |attr|
      parse(response.body).should have_key attr
    end
  end

  it "should have the correct links (statusable, user, self)" do
    get "/api/statuses/#{@activity.id}", :oauth_token => @token, :format => 'json'
    entity = parse(response.body)

    %w(statusable self user).each do |attr|
      get href_to(attr, entity), :format => 'json', :oauth_token => @token
      response.code.should_not be_nil
    end
  end

  context "when Answer type" do
    it "should return code 200" do
      answer = Factory(:answer, :user => @current_user)
      get "/api/statuses/#{answer.id}", :oauth_token => @token, :format => 'json'
      response.code.should == "200"
    end

    it "should have a link to activity (in_response_to)"
  end

  context "when Log type" do
    it "should return code 200" do
      answer = Factory(:answer, :user => @current_user)
      get "/api/statuses/#{answer.id}", :oauth_token => @token, :format => 'json'
      response.code.should == "200"
    end

    it "should have a link to logeable"
  end

  context "when Activity type" do
    it "should have a link to its Answers"
  end

  context "when listing User statuses" do
    it "should return code 200"
    it "should filter by status type (help)"
    it "should filter by status type (log)"
    it "should filter by status type (activity)"
  end

  context "when listing space statuses" do
    it "should return code 200"
    it "should filter by status type (help)"
    it "should filter by status type (log)"
    it "should filter by status type (activity)"
  end

  context "when listing lectures statuses" do
    it "should return code 200"
    it "should filter by status type (help)"
    it "should filter by status type (log)"
    it "should filter by status type (activity)"
  end
end

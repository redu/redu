require "api_spec_helper"

describe "Log" do
  let(:current_user) { Factory(:user) }
  let(:token) { _, _, token = generate_token(current_user); token }
  let(:space) do
    environment = Factory(:complete_environment, :owner => current_user)
    environment.courses.first.spaces.first
  end
  let(:log) do
    Factory(:log, :statusable => space, :user => current_user,
            :logeable => space)
  end
  let(:params) { { :oauth_token => token, :format => 'json'} }

  before do
    get "/api/statuses/#{log.id}", params
    @entity = parse(response.body)
  end

  it "should return code 200" do
    response.code.should == "200"
  end

  it "should have type, created_at and text" do
    %w(type created_at text logeable_type).each do |attr|
      @entity.should have_key attr
    end
  end

  it "should have the correct link to statusable, self, user and logeable" do
    %w(statusable self user logeable).each do |attr|
      get href_to(attr, @entity), params
      response.code.should == "200"
    end
  end

  it_should_behave_like "embeds user" do
    let(:embeder) { log }
    let(:user) { embeder.user }
    let(:entity) { @entity }
  end

end

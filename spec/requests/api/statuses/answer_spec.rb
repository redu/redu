# -*- encoding : utf-8 -*-
require "api_spec_helper"

describe "Answer" do
  let(:current_user) { Factory(:user) }
  let(:token) { _, _, token = generate_token(current_user); token }
  let(:activity) do
    Factory(:activity, :user => current_user, :statusable => current_user)
  end
  let(:answer) do
    Factory(:answer, :statusable => current_user,
            :user => current_user, :in_response_to => activity)
  end
  let(:params) { { :oauth_token => token, :format => 'json'} }

  before do
    get "/api/statuses/#{answer.id}", params
    @entity = parse(response.body)
  end

  it "should return code 200" do
    response.code.should == "200"
  end

  it "should have type, text, created_at" do
    %w(type text created_at).each do |attr|
      parse(response.body).should have_key attr
    end
  end

  it "should have the correct links (self, user, in_response_to and statusable)" do
    %w(self user in_response_to statusable).each do |attr|
      get href_to(attr, @entity), params
      response.code.should == "200"
    end
  end

  it_should_behave_like "embeds user" do
    let(:embeder) { answer }
    let(:user) { embeder.user }
    let(:entity) { @entity }
  end
end

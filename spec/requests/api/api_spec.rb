# -*- encoding : utf-8 -*-
require 'api_spec_helper'
describe 'API Authorization' do

  before do
    @application, @current_user, @token = generate_token

    @params = { name: 'New environment',
                  path: 'environment-path',
                  initials: 'NE' }
  end

  context 'when token sent by query string' do
    it "should create an environment" do
      post "/api/environments",
           environment: @params,
           oauth_token: @token,
           format: 'json'

      self_url = href_to("self", parse(response.body))

      get self_url,
          oauth_token: @token,
          format: 'json'

      response.code.should == '200'
    end
  end

  context 'when token sent by headers' do
    it "should create an environment" do
      post("/api/environments",
          {environment: @params, format: 'json' },
          {"HTTP_AUTHORIZATION" => "OAuth #{@token}"})

      self_url = href_to("self", parse(response.body))

      get(self_url, {format: 'json'}, {"HTTP_AUTHORIZATION" => "OAuth #{@token}"})
      response.code.should == '200'
    end
  end
end

# -*- encoding : utf-8 -*-
require 'api_spec_helper'

describe "Chat" do
  before do
    @application, @current_user, @token = generate_token(@user)
  end
  context "when GET /chats/:id" do
    let(:chat) { FactoryGirl.create(:chat, :user => @current_user) }
    it "should return status 200" do
      get "/api/chats/#{chat.id}", :oauth_token => @token, :format => 'json'
      response.code.should == "200"
    end

    it "should have the correct properties" do
      get "/api/chats/#{chat.id}", :oauth_token => @token, :format => 'json'
      resource = parse(response.body)

      %w(links created_at id).each do |property|
        resource.should have_key property
      end
    end

    it "should have the correct links" do
      get "/api/chats/#{chat.id}", :oauth_token => @token, :format => 'json'
      links = parse(response.body)['links'].collect! { |l| l.fetch('rel') }

      %w(self user contact chat_messages).each do |link|
        links.should include link
      end
    end

    it "should return 404 when doesnt exists" do
      get "/api/chats/122121", :oauth_token => @token, :format => 'json'
      response.code.should == "404"
    end

    it "should return 403 when access denied" do
      new_chat = FactoryGirl.create(:chat)
      get "/api/chats/#{new_chat.id}", :oauth_token => @token, :format => 'json'
      response.code.should == "401"
    end
  end

  context "when GET /users/:id/chats" do
    before do
      FactoryGirl.create(:chat, :user => @current_user)
    end

    it "should return code 200" do
      get "/api/users/#{@current_user.id}/chats", :oauth_token => @token,
        :format => 'json'

      response.code.should == "200"
    end

    it "should return a list of chats" do
      get "/api/users/#{ @current_user.id }/chats", :oauth_token => @token,
        :format => 'json'

      parse(response.body).should be_a Array
    end

    it "should return a list of chats where the user is the sender" do
      2.times { FactoryGirl.create(:chat, :contact => @current_user) }

      get "/api/users/#{@current_user.id}/chats", :oauth_token => @token,
        :format => 'json'

      parse(response.body).length.should == 1
    end
  end
end

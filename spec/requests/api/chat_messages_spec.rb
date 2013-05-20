# -*- encoding : utf-8 -*-
require 'api_spec_helper'

describe "Chat message" do
  before do
    @application, @current_user, @token = generate_token(@user)
  end
  context "when GET /chat_messages/:id" do
    let(:chat_message) do
      message = Factory(:chat_message, :user => @current_user)
      Chat.find_or_create_and_append(message)
      message
    end

    it "should return status 200" do
      get "/api/chat_messages/#{chat_message.id}", :oauth_token => @token,
        :format => 'json'

      response.code.should == "200"
    end

    it "should have the correct properties" do
      get "/api/chat_messages/#{chat_message.id}", :oauth_token => @token,
        :format => 'json'

      resource = parse(response.body)
      %w(links created_at id message).each do |property|
        resource.should have_key property
      end
    end

    it "should have the correct links" do
      get "/api/chat_messages/#{chat_message.id}", :oauth_token => @token,
        :format => 'json'

      links = parse(response.body)['links'].collect { |l| l.fetch "rel" }
      %w(contact user sender_chat receiver_chat self).each do |link|
        links.should include link
      end
    end
  end

  context "when GET /chats/:chat_id/chat_messages" do
    let(:chat_message) { Factory(:chat_message, :user => @current_user) }
    let(:chats) { Chat.find_or_create_and_append(chat_message) }

    it "should return code 200" do
      get "/api/chats/#{chats.first.id}/chat_messages", :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return a list of resources" do
      get "/api/chats/#{chats.first.id}/chat_messages", :oauth_token => @token,
        :format => 'json'

      parse(response.body).should be_a Array
    end
  end
end

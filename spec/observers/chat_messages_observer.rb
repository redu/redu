# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ChatMessageObserver do
  let(:chat_message) { Factory(:chat_message) }

  it "should create a chat on the first message betweeen two users" do
    ActiveRecord::Observer.with_observers(:chat_message_observer) do
      expect { chat_message }.to change(Chat, :count).by(2)
    end
  end

  it "should not create if already exists" do
    ActiveRecord::Observer.with_observers(:chat_message_observer) do
      expect {
        fst_message =  Factory(:chat_message)
        snd_message = Factory(:chat_message, :user => fst_message.user,
                              :contact => fst_message.contact)
      }.to change(Chat, :count).by(2)
    end
  end

  it "should associate the chat message to the chat" do
    ActiveRecord::Observer.with_observers(:chat_message_observer) do
      chat_message.chats.length.should == 2
    end
  end
end

# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Chat do
  it { should belong_to :user }
  it { should belong_to :contact }
  it { should have_many(:chat_messages).through(:chat_message_associations) }

  context "#create_for" do
    let(:user) { Factory(:user) }
    let(:contact) { Factory(:contact) }
    let(:chat_message) { Factory(:chat_message) }

    it "should respond to #create_for" do
      Chat.should respond_to :create_for
    end

    it "should create two chats for one chat message" do
      expect {
        Chat.create_for(chat_message)
      }.to change(Chat, :count).by(2)
    end

    it "should assing the chat_message user to the first chat user" do
      c, c2 = Chat.create_for(chat_message)
      c.user.should == chat_message.user
    end

    it "should assing the chat_message contact to the first chat contact" do
      c, c2 = Chat.create_for(chat_message)
      c.contact.should == chat_message.contact
    end

    it "should return two chats" do
      Chat.create_for(chat_message).should be_a Array
    end

    it "should not double create chat" do
      expect {
        2.times { Chat.create_for(chat_message) }
      }.to change(Chat, :count).by(2)
    end

    it "should return the existing record when double creating" do
      c1, c2 = Chat.create_for(chat_message)
      c3, c4 = Chat.create_for(chat_message)

      c3.should == c1
      c4.should == c2
    end
  end

  context ".find_or_create_and_append" do
    let(:user) { Factory(:user) }
    let(:contact) { Factory(:contact) }
    let(:chat_message) { Factory(:chat_message) }

    it "should assing the chat_message for the first chat" do
      c, c2 = Chat.find_or_create_and_append(chat_message)
      c.chat_messages.should include chat_message
    end

    it "should assing the chat_message for the second chat" do
      c, c2 = Chat.find_or_create_and_append(chat_message)
      c2.chat_messages.should include chat_message
    end

    it "should append to a existing  first chat" do
      Chat.find_or_create_and_append(chat_message)
      new_message = Factory(:chat_message, :user => chat_message.user,
                            :contact => chat_message.contact)
      c1, c2 = Chat.find_or_create_and_append(new_message)
      c1.chat_messages.length.should == 2
    end

    it "should append to a existing second chat" do
      Chat.find_or_create_and_append(chat_message)
      new_message = Factory(:chat_message, :user => chat_message.user,
                            :contact => chat_message.contact)
      c1, c2 = Chat.find_or_create_and_append(new_message)
      c2.chat_messages.length.should == 2
    end
  end
end

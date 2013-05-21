# -*- encoding : utf-8 -*-
require 'api_spec_helper'
require 'cancan/matchers'

describe "Chat ability" do
  let(:user) { FactoryGirl.create(:user) }
  subject { Api::Ability.new(user) }

  context "when chat user" do
    let(:own_chat) { FactoryGirl.create(:chat, :user => user) }
    let(:other_chat) { FactoryGirl.create(:chat, :contact => user) }

    it "should be able to manage his own chat" do
      subject.should be_able_to :manage, own_chat
    end
  end

  context "when chat contact" do
    let(:own_chat) { FactoryGirl.create(:chat, :contact => user) }

    it "should not be able to manage the chat he is contact" do
      subject.should_not be_able_to :manage, own_chat
    end
  end

  context "when strange" do
    let(:stange_chat) { FactoryGirl.create(:chat) }

    it "should not be able to manage others chats" do
      subject.should_not be_able_to :manage, stange_chat
    end
  end
end


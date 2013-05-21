# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'authlogic/test_case'

describe MessagesController do
  context "POST delete_selected" do
    before do
      @user = FactoryGirl.create(:user)
      @messages = 5.times.collect { FactoryGirl.create(:message, :recipient => @user) }
      login_as @user

      @messages_to_delete = @messages[0..2]
      @params = { :mailbox => "inbox",
                  :delete => @messages_to_delete.collect(&:id) }

      @params.merge!({:locale => "pt-BR", :user_id => @user.login})
      post :delete_selected, @params
    end

    it "mark all indicated messages as deleted" do
      Message.where(:recipient_id => @user.id, :recipient_deleted => true).to_set.
        should == @messages_to_delete.to_set
    end

    context "when trying to mark others messages as deleted" do
      before do
        @others_messages = 3.times.collect { FactoryGirl.create(:message) }
        @params = {:mailbox => "inbox",
                   :delete => @others_messages.collect(&:id) }

        @params.merge!({:locale => "pt-BR", :user_id => @user.login})
        post :delete_selected, @params
      end

      it "do not mark others messages as deleted" do
        @others_messages.each do |m|
          m.sender_deleted.should be_false
          m.recipient_deleted.should be_false
        end
      end
    end
  end
end


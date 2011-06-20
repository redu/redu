require 'spec_helper'

describe ChatMessage do

  it { should belong_to :user }
  it { should belong_to :contact }

  before do
    @user = Factory(:user)
    @contact1 = Factory(:user)
    @contact2 = Factory(:user)

    @message1 = Factory(:chat_message, :user => @user, :contact => @contact1)
    @message2 = Factory(:chat_message, :user => @user, :contact => @contact2)
    @message3 = Factory(:chat_message, :user => @contact1, :contact => @contact2)
    @message4 = Factory(:chat_message, :user => @contact2, :contact => @user)
  end

  it "should retrieve a log of a user" do
    @user.chat_messages.log(1.day.ago, 20).should == [@message1, @message2, @message4]
  end
end

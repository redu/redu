require 'spec_helper'

describe ChatMessage do

  it { should belong_to :user }
  it { should belong_to :contact }
  it { should have_many(:chats).through(:chat_message_associations) }

  before do
    @user = Factory(:user)
    @contact1 = Factory(:user)
    @contact2 = Factory(:user)


    @message1 = Factory(:chat_message, :user => @user, :contact => @contact1, :created_at => 2.days.ago)
    @message2 = Factory(:chat_message, :user => @user, :contact => @contact1)
    @message3 = Factory(:chat_message, :user => @contact1, :contact => @user)
    @message4 = Factory(:chat_message, :user => @user, :contact => @contact1)
    @message5 = Factory(:chat_message, :user => @user, :contact => @contact2)
    @message6 = Factory(:chat_message, :user => @contact1, :contact => @contact2)
    @message7 = Factory(:chat_message, :user => @contact2, :contact => @user)
  end

  it "should retrieve a log of a user" do
    ChatMessage.log_by_time_and_limit(@user, @contact1, 1.day.ago, 20).should == [@message2, @message3, @message4]
  end

  it "should retrieve a list of hash with all informations" do
    list_of_users = ChatMessage.log(@contact2, @contact1, 1.day.ago, 20)
    # o time é removido, pois na comparação não retornava igualdade
    list_of_users = list_of_users.collect do |elem|
      elem.reject! { |k, v| k == :time }
    end

    list_of_users.should ==
      [{:name => @contact1.display_name, :user_id => @contact1.id, :text => @message6.message,
      :thumbnail => @contact1.avatar.url(:thumb_24)}]
  end

  it "should retrieve a list of hash with all informations" do
    list_of_users = ChatMessage.log(@user, @contact1, 1.day.ago, 20)
    # o time é removido, pois na comparação não retornava igualdade
    list_of_users = list_of_users.collect do |elem|
      elem.reject! { |k, v| k == :time }
    end

    list_of_users.should ==
      [
        {:name => @user.display_name, :user_id => @user.id, :text => @message2.message,
         :thumbnail => @user.avatar.url(:thumb_24)},
        {:name => @contact1.display_name, :user_id => @contact1.id, :text => @message3.message,
         :thumbnail => @contact1.avatar.url(:thumb_24)},
        {:name => @user.display_name, :user_id => @user.id, :text => @message4.message,
         :thumbnail => @user.avatar.url(:thumb_24)}
      ]
  end

  it "should retrieve the 3 LAST log messages" do
    @more_recent_message1 = Factory(:chat_message, :user => @user,
                                    :contact => @contact1,
                                    :created_at => @message2.created_at + 1.minutes)
    @more_recent_message2 = Factory(:chat_message, :user => @user,
                                    :contact => @contact1,
                                    :created_at => @message2.created_at + 2.minutes)
    @more_recent_message3 = Factory(:chat_message, :user => @user,
                                    :contact => @contact1,
                                    :created_at => @message2.created_at + 3.minutes)
    list_of_users = ChatMessage.log(@user, @contact1, 1.day.ago, 3)
    # o time é removido, pois na comparação não retornava igualdade
    list_of_users = list_of_users.collect do |elem|
      elem.reject! { |k, v| k == :time }
    end
    list_of_users.should ==
      [
        {:name => @user.display_name, :user_id => @user.id,
          :text => @more_recent_message1.message,
          :thumbnail => @user.avatar.url(:thumb_24)},
        {:name => @user.display_name, :user_id => @user.id,
          :text => @more_recent_message2.message,
          :thumbnail => @user.avatar.url(:thumb_24)},
        {:name => @user.display_name, :user_id => @user.id,
          :text => @more_recent_message3.message,
          :thumbnail => @user.avatar.url(:thumb_24)},
    ]
  end
end

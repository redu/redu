require 'spec_helper'
require 'authlogic/test_case'

describe PresenceController do
  render_views

  before do
    @current_user = Factory(:user)
    @friend1 = Factory(:user)
    @friend2 = Factory(:user)
    @friend3 = Factory(:user)
    @user2 = Factory(:user)
    @user3 = Factory(:user)

    # primeiro curso
    environment = Factory(:environment)
    course = Factory(:course, :owner => environment.owner,
                     :environment => environment)
    space = Factory(:space, :owner => environment.owner,
                    :course => course)

    # segundo curso
    course2 = Factory(:course, :environment => environment,
                      :owner => environment.owner)
    course3 = Factory(:course)

    course.join(@current_user)
    course2.join(@current_user)

    course.join(@friend1, Role[:teacher])
    course2.join(@friend1, Role[:tutor])

    course.join(@friend2)
    course3.join(@user2)

    @current_user.be_friends_with(@friend1)
    @friend1.be_friends_with(@current_user)
    @current_user.be_friends_with(@friend2)
    @friend2.be_friends_with(@current_user)
    @current_user.be_friends_with(@friend3)
    @friend3.be_friends_with(@current_user)
    login_as @current_user

    @presence = Presence.new(@current_user)
  end

  context "POST 'auth'" do

    context "authenticating" do

      context "own presence channel" do

        before do
          post :auth, :locale => "pt-BR",
            :channel_name => "presence-user-#{@current_user.id}",
          :socket_id => "539.9111", :user_id => @current_user.id

        end

        it "should be successful" do
          response.should be_success
        end

        it "should return a list of contacts and user_id" do
          payload = {:user_id => @current_user.id,
            :user_info => {
            :contacts => @presence.channels} }

          user_info = JSON.parse(response.body)
          user_info["channel_data"].should == payload.to_json
        end

      end

      context "private channel" do
        before do
          post :auth, :locale => "pt-BR",
            :channel_name => "private-#{@current_user.id}-#{@friend1.id}",
          :socket_id => "123.13865", :user_id => @current_user.id
        end

        it "should be successful" do
          response.should be_success
        end

        it "should retrive an auth key" do
          json_response = JSON.parse(response.body)
          json_response.should have_key("auth")
        end
      end

      context "when subscribing to a contact's channel" do

        before do
          post :auth, :locale => "pt-BR",
            :channel_name => "presence-user-#{@friend1.id}",
          :socket_id => "213.2312", :user_id => @current_user.id
        end

        it "should be successful" do
          response.should be_success
        end

        it "return name, thumbnail and channel of current_user" do
          payload = { :user_id => @current_user.id,
            :user_info => { :name => @current_user.display_name,
            :thumbnail => @current_user.avatar.url(:thumb_24),
            :pre_channel => @current_user.presence_channel,
            :pri_channel => @current_user.private_channel_with(@friend1),
            :roles => @presence.fill_roles }}

          user_info = JSON.parse(response.body)
          user_info["channel_data"].should == payload.to_json
        end
      end
    end

    context "when subscribing a strange channel" do

      context "on presence -" do
        before do
          post :auth, :locale => "pt-BR",
            :channel_name => "presence-user-#{@user2.id}",
          :socket_id => "212.2113", :user_id => @current_user.id
        end

        it "should not be success" do
          response.should_not be_success
        end

      end

      context "on private -" do

        it "should not be success" do
          strange = Factory(:user)
          post :auth, :locale => "pt-BR",
            :channel_name => "private-#{@friend1.id}-#{strange.id}",
            :socket_id => "123.13865", :user_id => @current_user.id

          response.should_not be_success
        end

        it "should not be success" do
          strange = Factory(:user)
          post :auth, :locale => "pt-BR",
            :channel_name => "private-#{@friend1.id}-#{@friend2.id}",
            :socket_id => "123.13865", :user_id => @current_user.id

          response.should_not be_success
        end

        it "should not be success" do
          strange = Factory(:user)
          post :auth, :locale => "pt-BR",
            :channel_name => "private-#{@current_user.id}-#{strange.id}",
            :socket_id => "123.13865", :user_id => @current_user.id

          response.should_not be_success
        end

      end

    end

    context "when subscribing to multiple channels" do
      before do
        @chs = ["presence-user-#{@friend1.id}",
                "private-#{@current_user.id}-#{@friend1.id}",
                "presence-user-#{@friend2.id}",
                "private-#{@current_user.id}-#{@friend2.id}"]
      end

      it "should be successful" do
        post :multiauth, :locale => "pt-BR", :channels => @chs,
          :socket_id => "123.13865", :user_id => @current_user.id

        response.should be_success
      end

      it "should return a multiresponse" do
        post :multiauth, :locale => "pt-BR", :channels => @chs,
          :socket_id => "123.13865", :user_id => @current_user.id

        user_info = JSON.parse(response.body)
        user_info.should have_key "presence-user-#{@friend1.id}"
        user_info.should have_key "presence-user-#{@friend2.id}"
        user_info.should have_key "private-#{@current_user.id}-#{@friend1.id}"
        user_info.should have_key "private-#{@current_user.id}-#{@friend2.id}"
      end
    end
  end

  context "POST send_chat_message" do
    before do
      @user = Factory(:user)
      @contact = Factory(:user)
      @user.be_friends_with(@contact)
      @contact.be_friends_with(@user)
      login_as @user

      @post_params = { :locale => "pt-BR",
        :contact_id => @contact.id, :text => "Hello, buddy!" }
    end

    it "should be successful" do
      post :send_chat_message, @post_params
      response.should be_success
    end

    it "triggers an 'message_received' pusher event" do
      pending do
        data = { :thumbnail => @user.avatar.url(:thumb_24),
          :text => @post_params[:text], :time => Time.now,
          :name => @user.display_name,
          :user_id => @user.id }
        Pusher.any_instance.stub(:trigger!)
        Pusher.should_receive(:trigger!).with('message_sent', data)
        post :send_chat_message, @post_params
      end
    end

    it "creates a ChatMessage" do
      expect {
        post :send_chat_message, @post_params
      }.to change(ChatMessage, :count).by(1)
      message = ChatMessage.last
      message.user.should == @user
      message.contact.id.should == @post_params[:contact_id]
      message.message.should == @post_params[:text]
    end

    it "returns status and time" do
      post :send_chat_message, @post_params
      payload = { :status => 200, :time => Time.zone.now.strftime("hoje, %H:%M") }

      response.body.should == payload.to_json
    end
  end

  context "GET last_messages_with" do
    before do
      @user = Factory(:user)
      @contact1 = Factory(:user)
      @contact2 = Factory(:user)
      @user.be_friends_with(@contact1)
      @contact1.be_friends_with(@user)
      @user.be_friends_with(@contact2)
      @contact2.be_friends_with(@user)
      login_as @user

      @message1 = Factory(:chat_message, :user => @user, :contact => @contact1, :created_at => 2.days.ago)
      @message2 = Factory(:chat_message, :user => @user, :contact => @contact1)
      @message5 = Factory(:chat_message, :user => @user, :contact => @contact2)
      @message3 = Factory(:chat_message, :user => @contact1, :contact => @user)
      @message6 = Factory(:chat_message, :user => @contact1, :contact => @contact2)
      @message4 = Factory(:chat_message, :user => @user, :contact => @contact1)
      @message7 = Factory(:chat_message, :user => @contact2, :contact => @user)

      Factory(:chat_message, :message => "Hooray! old",
              :user => @user, :contact => @contact1, :created_at => 2.days.ago)
      get :last_messages_with, :locale => "pt-BR", :contact_id => @contact1.id
    end

    it "should be successful" do
      response.should be_success
    end

    it "returns log conversation" do
      payload = [ {:name => @user.display_name, :user_id => @user.id,
        :text => @message2.message, :thumbnail => @user.avatar.url(:thumb_24),
        :time => ChatMessage.format_time(@message2.created_at)},
        {:name => @contact1.display_name, :user_id => @contact1.id,
          :text => @message3.message, :thumbnail => @contact1.avatar.url(:thumb_24),
          :time => ChatMessage.format_time(@message3.created_at)},
        {:name => @user.display_name, :user_id => @user.id,
          :text => @message4.message, :thumbnail => @user.avatar.url(:thumb_24),
          :time => ChatMessage.format_time(@message4.created_at)} ]
      response.body.should == payload.to_json
    end
  end
end

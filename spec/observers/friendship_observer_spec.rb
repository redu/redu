# -*- encoding : utf-8 -*-
require 'spec_helper'

describe FriendshipObserver do
  context "logger" do
    it "logs firendship" do
      ActiveRecord::Observer.with_observers(:friendship_observer) do
        @user1 = Factory(:user)
        @user2 = Factory(:user)

        expect {
          @user1.be_friends_with(@user2)
          @user2.be_friends_with(@user1)
        }.to change(Log, :count).by(2)
      end
    end
  end

  context "mailer" do
    before do
      UserNotifier.delivery_method = :test
      UserNotifier.perform_deliveries = true
      UserNotifier.deliveries = []
    end

    it "notifies the request" do
      neo = Factory(:user)
      2.times do
        e = Factory(:environment, :owner => neo)
        Factory(:course, :environment => e, :owner => neo)
      end
      smith = Factory(:user)

      ActionMailer::Base.register_observer(UserNotifierObserver)
      ActiveRecord::Observer.with_observers(:friendship_observer) do
        expect {
          neo.be_friends_with(smith)
        }.to change(UserNotifier.deliveries, :count).by(1)
        UserNotifier.deliveries.last.subject.should \
          == "#{neo.display_name} quer se conectar"
        UserNotifier.deliveries.last.text_part.to_s.should \
          =~ /2 cursos/
      end
    end
  end
end

require 'spec_helper'

describe UserObserver do
  context "logger" do
    it "logs user update" do
      ActiveRecord::Observer.with_observers(:user_observer) do
        user = Factory(:user)
        expect {
          user.first_name = "Guilherme"
          user.save
        }.should change(user.logs, :count).by(1)
      end
    end

    it "cannot log if it changes a non logable attribute" do
      ActiveRecord::Observer.with_observers(:user_observer) do
        user = Factory(:user)
        expect {
          user.score = 10
          user.save
        }.should_not change(user.logs, :count)
      end
    end
  end

  context "mailer" do
    before do
      UserNotifier.delivery_method = :test
      UserNotifier.perform_deliveries = true
      UserNotifier.deliveries = []
    end

    it "notifies the signup" do
      ActiveRecord::Observer.with_observers(:user_observer) do
        expect {
          Factory(:user)
        }.should change(UserNotifier.deliveries, :count).by(1)
      end
    end
  end
end

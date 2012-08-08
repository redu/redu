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

  context "OAuth AccessToken" do
    it "creates an AccessToken for the user" do
      ActiveRecord::Observer.with_observers(:user_vis_application_observer) do
        expect {
          ClientApplication.create(:name => "ReduViz", :url => "http://www.redu.com.br")
          user = Factory(:user)
        }.should change(Oauth2Token, :count).by(1)
      end
    end
  end

  context "Redu Course" do
    it "associates to Redu environment" do
      ActiveRecord::Observer.with_observers(:user_observer) do
        environment = Factory(:environment, :path => "ava-redu")
        courses = 3.times.inject([]) do |acc,i|
          acc << Factory(:course,
                         :environment => environment,
                         :owner => environment.owner)
        end

        user = Factory(:user)
        user.courses.to_set.should == courses.to_set
      end
    end

    context "when there are no environment" do
      it "associates to Redu environment" do
        expect {
          user = Factory(:user)
        }.should_not raise_error
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

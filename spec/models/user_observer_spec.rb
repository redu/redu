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
  end
end

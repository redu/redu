# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UserObserver do
  context "logger" do
    it "logs user update" do
      ActiveRecord::Observer.with_observers(:user_observer) do
        user = FactoryGirl.create(:user)
        expect {
          user.first_name = "Guilherme"
          user.save
        }.to change(user.logs, :count).by(1)
      end
    end

    it "cannot log if it changes a non logable attribute" do
      ActiveRecord::Observer.with_observers(:user_observer) do
        user = FactoryGirl.create(:user)
        expect {
          user.score = 10
          user.save
        }.to_not change(user.logs, :count)
      end
    end
  end
end

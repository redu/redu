# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UserWalledgardenAppsObserver do
  context "after_create" do
    before do
      FactoryBot.create(:client_application, :walledgarden => true)
    end

    it "creates an OAuth2Token for the user" do
      with_observers do
        expect { FactoryBot.create(:user) }.to change(Oauth2Token, :count).by(1)
      end
    end

    it "toches the user" do
      with_observers do
        user = FactoryBot.build(:user)
        user.should_receive(:update_attributes).once
        user.save
      end
    end

    it "touches the user once" do
      FactoryBot.create(:client_application, :walledgarden => true)

      with_observers do
        user = FactoryBot.build(:user)
        user.should_receive(:update_attributes).once
        user.save
      end
    end

    def with_observers(&block)
      ActiveRecord::Observer.with_observers(:user_walledgarden_apps_observer, &block)
    end
  end
end

require 'spec_helper'

describe UserWalledgardenAppsObserver do
  context "after_create" do
    before do
      Factory(:client_application, :walledgarden => true)
    end

    it "creates an OAuth2Token for the user" do
      ActiveRecord::Observer.with_observers(:user_walledgarden_apps_observer) do
        expect { Factory(:user) }.should change(Oauth2Token, :count).by(1)
      end
    end
  end
end

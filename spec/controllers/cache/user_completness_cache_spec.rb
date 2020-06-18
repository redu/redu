# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'UserCompletnessCache' do
  let(:user) { FactoryBot.create(:user) }

  context "user_completness_bar" do
    let(:cache_identifier) { "views/user_completness_bar/#{user.id}" }

    context "writing" do
      it_should_behave_like 'cache writing' do
        let(:controller) { UsersController.new }
        let(:requisition) { get :home, :id => user.to_param,
                            :locale => 'pt-BR' }
      end
    end

    context "expiration" do
      it "expires when user is updated" do
        ActiveRecord::Observer.with_observers(:user_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            user.update_attribute(:first_name, "Linda")

            cache.should_not exist(cache_identifier)
          end
        end
      end

      it "expires when user is destroyed" do
        ActiveRecord::Observer.with_observers(:user_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            user.destroy

            cache.should_not exist(cache_identifier)
          end
        end
      end
    end #expiration
  end
end

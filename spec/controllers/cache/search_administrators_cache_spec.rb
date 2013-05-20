# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'SearchAdministratorsCache' do
  let(:user) { Factory(:user) }
  let(:environment) { Factory(:environment) }

  context "search_environment_administrators" do
    let(:cache_identifier) { "views/search_environment_administrators/#{environment.id}" }

    context "writing" do
      let(:environments) { [environment] }

      before do
        mock_search_perform(environments, EnvironmentSearch)
      end

      it_should_behave_like 'cache writing' do
        let(:controller) { SearchController.new }
        let(:requisition) { get :environments, :f => ['ambientes'],
                            :q => 'Makeup', :locale => 'pt-BR' }
      end
    end

    context "expiration" do
      it "expires when admin user_environment_association is created" do
        ActiveRecord::Observer.with_observers(:user_environment_association_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            Factory(:user_environment_association, :user => user,
                    :environment => environment, :role => :environment_admin)

            cache.should_not exist(cache_identifier)
          end
        end
      end

      it "expires when user_environment_association is updated" do
        Factory(:user_environment_association, :user => user,
                :environment => environment)

        ActiveRecord::Observer.with_observers(:user_environment_association_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            environment.change_role(user, :environment_admin)

            cache.should_not exist(cache_identifier)
          end
        end
      end

      it "expires when admin user_environment_association is destroyed" do
        Factory(:user_environment_association, :user => user,
                :environment => environment, :role => :environment_admin)

        ActiveRecord::Observer.with_observers(:user_environment_association_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            environment.administrators.first.destroy

            cache.should_not exist(cache_identifier)
          end
        end
      end
    end
  end
end

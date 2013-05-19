require 'spec_helper'

describe 'ApplicationLayoutCache' do
  let(:user) { Factory(:user) }

  context 'nav_global_dropdown_menu' do
    def nav_global_dropdown_menu_identifier(user)
      "views/nav_global_dropdown_menu/#{user.id}"
    end

    let(:cache_identifier) { nav_global_dropdown_menu_identifier(user) }
    let(:environment) { Factory(:environment) }

    context 'writing' do
      it_should_behave_like 'cache writing' do # spec/support/cache_writing...
        let(:controller) { UsersController.new }
        let(:requisition) { get :home, :id => user.to_param, :locale => 'pt-BR' }
      end
    end

    context 'expiration' do
      it 'expires when a user receives a message' do
        ActiveRecord::Observer.with_observers(:message_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            Factory(:message, :recipient => user)

            cache.should_not exist(cache_identifier)
          end
        end
      end

      context 'when user receives a message' do
        let(:message) { Factory(:message, :recipient => user) }

        it 'expires when recipient reads an unread message' do
          ActiveRecord::Observer.with_observers(:message_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              Message.read_message(message.id, user)

              cache.should_not exist(cache_identifier)
            end
          end
        end

        it 'expires when recipient deletes a message' do
          ActiveRecord::Observer.with_observers(:message_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              message.mark_deleted(user)

              cache.should_not exist(cache_identifier)
            end
          end
        end

        it 'expires when both users delete a message' do
          message.mark_deleted(message.sender)

          ActiveRecord::Observer.with_observers(:message_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              message.mark_deleted(user)

              cache.should_not exist(cache_identifier)
            end
          end
        end
      end

      context 'when the user is updated' do
        it 'expires when user first_name is updated' do
          ActiveRecord::Observer.with_observers(:user_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              user.update_attribute(:first_name, "Changed")

              cache.should_not exist(cache_identifier)
            end
          end
        end

        it 'expires when user last_name is updated' do
          ActiveRecord::Observer.with_observers(:user_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              user.update_attribute(:last_name, "Changed")

              cache.should_not exist(cache_identifier)
            end
          end
        end

        it 'expires when user login is updated' do
          ActiveRecord::Observer.with_observers(:user_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              user.update_attribute(:login, "Changed")

              cache.should_not exist(cache_identifier)
            end
          end
        end
      end

      context 'when a partner there is a partner with admins' do
        let(:partner) { Factory(:partner) }
        let(:admins) { (1..5).collect { Factory(:user) } }

        before do
          admins.each do |u|
            partner.add_collaborator u
          end
        end

        it 'expires when a user is linked to a partner' do
          ActiveRecord::Observer.with_observers(
            :partner_user_association_cache_observer) do
              performing_cache(cache_identifier) do |cache|
                partner.add_collaborator user

                cache.should_not exist(cache_identifier)
              end
          end
        end

        context 'and user is an admin' do
          before do
            partner.add_collaborator user
          end

          it 'expires all admins nav account when partner is updated' do
            ActiveRecord::Observer.with_observers(:partner_cache_observer) do
              performing_cache(cache_identifier) do |cache|
                partner.update_attribute(:name, "Changed")

                cache.should_not exist(cache_identifier)
                admins.each do |admin|
                  cache.should_not exist(nav_global_dropdown_menu_identifier(admin))
                end
              end
            end
          end

          it 'expires when a user is removed from a partner' do
            ActiveRecord::Observer.with_observers(
              :partner_user_association_cache_observer) do
                performing_cache(cache_identifier) do |cache|
                  partner.partner_user_associations.last.destroy

                  cache.should_not exist(cache_identifier)
                end
            end
          end
        end
      end
    end
  end
end

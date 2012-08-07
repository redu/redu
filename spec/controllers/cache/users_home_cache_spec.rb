require 'spec_helper'

describe 'UsersHomeCache' do
  let(:user) { Factory(:user) }

  context 'home_sidebar_environments' do
    def sidebar_environments_identifier(user)
      "views/home_sidebar_environments/#{user.id}"
    end

    let(:cache_identifier) { sidebar_environments_identifier(user) }

    context 'writing' do
      it_should_behave_like 'cache writing' do # spec/support/cache_writing...
        let(:controller) { UsersController.new }
        let(:requisition) { get :home, :id => user.to_param, :locale => 'pt-BR' }
      end
    end

    context 'expiration' do
      let(:environment) { Factory(:environment) }

      it 'expires when user enters in an environment' do
        ActiveRecord::Observer.with_observers(
          :user_environment_association_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              environment.users << user
              cache.should_not exist(cache_identifier)
            end
        end
      end

      it 'expires when user goes out from an environment' do
        environment.users << user

        ActiveRecord::Observer.with_observers(
          :user_environment_association_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            user.user_environment_associations.last.destroy
            cache.should_not exist(cache_identifier)
          end
        end
      end
    end
  end

  context 'home_sidebar_connections' do
    def sidebar_connections_identifier(user)
      "views/home_sidebar_connections/#{user.id}"
    end

    let(:cache_identifier) { sidebar_connections_identifier(user) }

    context 'writing' do
      it_should_behave_like 'cache writing' do # spec/support/cache_writing...
        let(:controller) { UsersController.new }
        let(:requisition) { get :home, :id => user.to_param, :locale => 'pt-BR' }
      end
    end

    context 'expiration' do
      context 'when a friendship request is made' do
        let(:friend) { Factory(:user) }
        let(:friendship) { user.be_friends_with(friend)[0] }

        it 'expires when a friendship request is accepted' do
          ActiveRecord::Observer.with_observers(:friendship_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              friendship.accept!

              cache.should_not exist(cache_identifier)
            end
          end
        end

        it 'expires when a friendship is sadly destroyed :(' do
          ActiveRecord::Observer.with_observers(:friendship_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              friendship.destroy

              cache.should_not exist(cache_identifier)
            end
          end
        end
      end
    end
  end


  context 'home_friends_requisitions' do
    def friends_requisitions_identifier(user)
      "views/home_friends_requisitions/#{user.id}"
    end

    let(:cache_identifier) { friends_requisitions_identifier(user) }

    context 'writing' do
      it_should_behave_like 'cache writing' do # spec/support/cache_writing...
        let(:controller) { UsersController.new }
        let(:requisition) { get :home, :id => user.to_param, :locale => 'pt-BR' }
      end
    end

    context 'expiration' do
      let(:friend) { Factory(:user) }

      it 'expires when a new friendship request is made' do
        ActiveRecord::Observer.with_observers(:friendship_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            friend.be_friends_with(user)

            cache.should_not exist(cache_identifier)
          end
        end
      end

      context 'when a friendship request is made' do
        before do
          friend.be_friends_with(user)
        end

        it 'expires when a friendship resquest is rejected (destroyed) :(' do
          ActiveRecord::Observer.with_observers(:friendship_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              user.friendship_for(friend).destroy

              cache.should_not exist(cache_identifier)
            end
          end
        end

        it 'expires when a friendship resquest is accepted o/' do
          ActiveRecord::Observer.with_observers(:friendship_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              user.be_friends_with(friend)

              cache.should_not exist(cache_identifier)
            end
          end
        end

        it 'expires when the users first name is updated' do
          ActiveRecord::Observer.with_observers(:user_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              friend.update_attribute(:first_name, 'Changed')

              cache.should_not exist(cache_identifier)
            end
          end
        end

        it 'expires when the users last name is updated' do
          ActiveRecord::Observer.with_observers(:user_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              friend.update_attribute(:last_name, 'Changed')

              cache.should_not exist(cache_identifier)
            end
          end
        end

        it 'expires when the users login is updated' do
          ActiveRecord::Observer.with_observers(:user_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              friend.update_attribute(:login, 'Changed')

              cache.should_not exist(cache_identifier)
            end
          end
        end
      end
    end
  end

  context 'home_courses_requisitions' do
    def courses_requisitions_identifier(user)
      "views/home_courses_requisitions/#{user.id}"
    end

    let(:cache_identifier) { courses_requisitions_identifier(user) }

    context 'writing' do
      it_should_behave_like 'cache writing' do # spec/support/cache_writing...
        let(:controller) { UsersController.new }
        let(:requisition) { get :home, :id => user.to_param, :locale => 'pt-BR' }
      end
    end

    context 'expiration' do
      let(:course) { Factory(:course) }
      let(:invited_users) do
        (1..3).collect { course.invite(Factory(:user)).user }
      end
      let(:pending_identifiers) do
        invited_users.collect { |u| courses_requisitions_identifier(u) }
      end

      before do
        (1..3).each { course.join Factory(:user) }
      end

      it 'expires when a course invitation is made' do
        ActiveRecord::Observer.with_observers(
          :user_course_association_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              course.invite(user)

              cache.should_not exist(cache_identifier)
            end
        end
      end

      context 'when a user is invited' do
        let(:uca) { course.invite(user) }

        it 'expires all pending requisitions when a course invitation '\
          ' is accepted' do
          all_identifiers = pending_identifiers + [cache_identifier]

          ActiveRecord::Observer.with_observers(
            :user_course_association_cache_observer) do
            performing_cache(all_identifiers) do |cache|
              uca.accept!

              cache.should_not exist(cache_identifier)
              all_identifiers.each do |identifier|
                cache.should_not exist(identifier)
              end
            end
          end
        end

        it 'expires when a course invitation is denied' do
          ActiveRecord::Observer.with_observers(
            :user_course_association_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              uca.deny!

              cache.should_not exist(cache_identifier)
            end
          end
        end
      end

      it 'expires all pending requisitions when a user goes out from '\
      'a course' do
        course.join user

        ActiveRecord::Observer.with_observers(
          :user_course_association_cache_observer) do
            performing_cache(pending_identifiers) do |cache|
              course.user_course_associations.last.destroy

              pending_identifiers.each do |identifier|
                cache.should_not exist(identifier)
              end
            end
        end
      end

      it 'expires all pending requisitions when the course is updated' do
        ActiveRecord::Observer.with_observers(:course_cache_observer) do
            performing_cache(pending_identifiers) do |cache|
              course.update_attribute(:name, 'Changed')

              pending_identifiers.each do |identifier|
                cache.should_not exist(identifier)
              end
            end
        end
      end
    end
  end
end

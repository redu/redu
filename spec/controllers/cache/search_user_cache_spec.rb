require 'spec_helper'

describe 'SearchUserCache' do
  let(:user) { Factory(:user) } # current_user
  let(:other_user) { Factory(:user) }

  context 'search_user_courses_count' do
    # A cache é feita pelo usuário que será mostrado
    let(:cache_identifier) { "views/search_user_courses_count/#{other_user.id}" }

    context 'writing' do
      let(:users) { [other_user] }

      before do
        # Necessário para a chamada da paginação na view
        users.stub!(:current_page).and_return(1)
        users.stub!(:num_pages).and_return(1)
        users.stub!(:limit_value).and_return(1)

        # Stub para resultado da busca com o sunspot
        UserSearch.stub_chain(:perform, :results).and_return(users)
      end

      it_should_behave_like 'cache writing' do # spec/support/cache_writing...
        let(:controller) { SearchController.new }
        let(:requisition) { get :profiles, :q => 'Makeup', :locale => 'pt-BR' }
      end
    end

    context "expiration" do
      before do
        @course = Factory(:course)
      end

      it "expires when user_course_association is created" do
        ActiveRecord::Observer.with_observers(:user_course_association_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            @course.join(other_user)

            cache.should_not exist(cache_identifier)
          end
        end
      end

      it "expires when user_course_association is destroied" do
        ActiveRecord::Observer.with_observers(:user_course_association_cache_observer) do
          @course.join(other_user)
          performing_cache(cache_identifier) do |cache|
            uca = UserCourseAssociation.where(:user_id => other_user.id,
                                              :course_id => @course.id).first
            uca.destroy
            cache.should_not exist(cache_identifier)
          end
        end
      end
    end
  end
end
